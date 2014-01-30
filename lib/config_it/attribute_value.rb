require 'coercible'

module ConfigIt
  class AttributeValue

    def initialize(value, options = {})
      @type = options[:type]
      @default_value = options[:default]
      @value = coerced_value(@type, value)
    end

    def value
      @value || @default_value
    end

    def value=(value)
      @value = coerced_value(@type, value)
    end

    def to_hash
      value
    end

  private

    def coerced_value(type, value)
      if type && [:boolean, :date, :datetime, :float, :integer].include?(type.to_sym) && value
        if value.is_a?(Array)
          value.map{ |v| safe_coercion(type, v) }
        else
          safe_coercion(type, value)
        end
      else
        value
      end
    end

    def safe_coercion(type, value)
      Coercible::Coercer.new[value.class].send("to_#{type}", value)
    end
  end
end
