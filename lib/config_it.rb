require "config_it/version"

class ConfigIt
  def self.attribute(name, options = {})
    define_method(name) do
      default_value = options[:default]
      instance_variable_get("@#{name}") || default_value
    end

    define_method("#{name}=") do |value|
      instance_variable_set("@#{name}", value)
    end

    @attributes = Array[@attributes] << name.to_sym
  end

  def self.group(name)
    define_method(name) do
      unless attribute_group = instance_variable_get("@#{name}")
        klass = self.class.const_get("Child")
        attribute_group = klass.new
        instance_variable_set("@#{name}", attribute_group)
      end
      attribute_group
    end
  end

  def to_hash

  end
end
