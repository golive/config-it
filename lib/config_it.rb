require "config_it/version"
require "config_it/attribute_value"
require "config_it/errors"
require "config_it/string"
require 'active_model'

class ConfigIt
  include ActiveModel::Validations

  def self.attribute_names
    @attribute_names ||= {}
  end

  def self.attribute_groups
    @attribute_groups ||= {}
  end

  def initialize(attrs = {})
    @attributes = {}

    self.class.attribute_names.each do |name, options|
      initialize_attribute(name, attrs[name.to_s] || attrs[name] || options[:default], options)
    end

    self.class.attribute_groups.each do |name, options|
      initialize_group(name, attrs[name.to_s] || attrs[name] || {}, options)
    end
  end

  def self.attribute(name, options = {})
    attribute_names[name.to_sym] = options

    define_method(name) do
      instance_variable_get("@#{name}").value
    end

    define_method("#{name}=") do |value|
      attr_value = instance_variable_get("@#{name}")
      attr_value.value = value
    end
  end

  def initialize_attribute(name, value, options)
    attr_value = instance_variable_set("@#{name}", ConfigIt::AttributeValue.new(value, options))
    @attributes[name.to_sym] ||= attr_value
  end

  def self.group(name, options = {})
    attribute_groups[name.to_sym] = options

    define_method(name) do
      instance_variable_get("@#{name}")
    end
  end

  def initialize_group(name, values, options)
    class_name = options[:class_name] || name.to_s.classify
    klass = options[:class_name] && Object.module_eval("::#{class_name}") || self.class.const_get(class_name)
    attribute_group = klass.new(values)
    instance_variable_set("@#{name}", attribute_group)
    @attributes[name.to_sym] ||= attribute_group
  rescue NameError
    raise ConfigError, "Configuration not avaliable for group #{name}. #{class_name} class is not defined."
  end

  def to_hash
    @attributes.inject({}) do |hash, (attr, value)|
      hash[attr] = value.to_hash
      hash
    end
  end

  def group_attributes
    self.class.attribute_groups.collect { |name, value| @attributes[name] }
  end

  def valid?(context = nil)
    if context && self.class.attribute_groups[context.to_sym]
      @attributes[context.to_sym].valid?
    elsif context && self.class.attribute_names[context.to_sym]
      super(context)
    else
      super && group_attributes.all?(&:valid?)
    end
  end

end
