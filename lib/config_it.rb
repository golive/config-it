require 'config_it/version'
require 'config_it/attribute_value'
require 'config_it/errors'
require 'active_model'


module ConfigIt

  def self.included(base)
    base.send :include, ActiveModel::Validations
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def attribute_names
      @attribute_names ||= {}
    end

    def attribute_groups
      @attribute_groups ||= {}
    end

    def attribute(name, options = {})
      attribute_names[name.to_sym] = options

      define_method(name) do
        instance_variable_get("@#{name}").value
      end

      define_method("#{name}=") do |value|
        attr_value = instance_variable_get("@#{name}")
        attr_value.value = value
      end
    end
    alias_method :field, :attribute

    def group(name, options = {})
      attribute_groups[name.to_sym] = options

      define_method(name) do
        instance_variable_get("@#{name}")
      end
    end
  end

  module InstanceMethods
    def initialize(attrs = {})
      @attributes = {}

      self.class.attribute_names.each do |name, options|
        initialize_attribute(name, attrs[name.to_s] || attrs[name] || options[:default], options)
      end

      self.class.attribute_groups.each do |name, options|
        initialize_group(name, attrs[name.to_s] || attrs[name] || {}, options)
      end
    end

    def initialize_attribute(name, value, options)
      attr_value = instance_variable_set("@#{name}", ConfigIt::AttributeValue.new(value, options))
      @attributes[name.to_sym] ||= attr_value
    end

    def initialize_group(name, values, options)
      class_name = options[:class_name] || name.to_s.split(/_/).map(&:capitalize).join
      klass = options[:class_name] && Object.module_eval("::#{class_name}") || self.class.const_get(class_name)
      attribute_group = klass.new(values)
      instance_variable_set("@#{name}", attribute_group)
      @attributes[name.to_sym] ||= attribute_group
    rescue NameError
      raise ConfigIt::ConfigError, "Configuration not avaliable for group #{name}. #{class_name} class is not defined."
    end

    def to_hash
      @attributes.inject({}) do |hash, (attr, value)|
        hash[attr] = value.to_hash
        hash
      end
    end

    def valid?(context = nil)
      super(context) & self.class.attribute_groups.inject(true) do |valid, (group_name, options)|
        valid &= (@attributes[group_name].valid?(context) || !self.errors.add(group_name, :invalid))
      end
    end
  end

end
