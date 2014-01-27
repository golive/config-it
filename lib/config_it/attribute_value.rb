require 'coercible'

class ConfigIt::AttributeValue

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
    type = type && {'boolean' => :boolean, 'date' => :date, 'datetime' => :datetime, 'float' => :float, 'integer' => :integer}[type.to_s]
    if type && value
      Coercible::Coercer.new[value.class].send("to_#{type}", value)
    else
      value
    end
  end
end
