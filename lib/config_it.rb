require "config_it/version"
require "config_it/attribute_value"

class ConfigIt

  def initialize(attributes = {})
    @attributes = {}
    # inicialitzar els attributs
  end

  def self.attribute_names
    @attribute_names ||= []
  end

  def self.attribute(name, options = {})
    define_method(name) do
      attr_value = instance_variable_get("@#{name}") || instance_variable_set("@#{name}", ConfigIt::AttributeValue.new(options[:default]))
      attributes[name.to_sym] ||= attr_value
      attr_value.value
    end

    define_method("#{name}=") do |value|
      if attr_value = instance_variable_get("@#{name}")
        attr_value.value = value
      else
        attr_value = instance_variable_set("@#{name}", ConfigIt::AttributeValue.new(value))
      end
      attr_value.value
    end

    attribute_names << name.to_sym
  end

  def self.group(name)
    define_method(name) do
      unless attribute_group = instance_variable_get("@#{name}")
        klass = self.class.const_get("Child")
        attribute_group = klass.new
        instance_variable_set("@#{name}", attribute_group)
      end
      attributes[name.to_sym] ||= attribute_group
    end

    attribute_names << name.to_sym
  end

  def to_hash
    self.class.attribute_names.each do |attr|
      public_send(attr)
    end

    attributes.inject({}) do |hash, (attr, value)|
      hash[attr] = value.to_hash
      hash
    end
  end

private

  def attributes
    @attributes
  end
end
