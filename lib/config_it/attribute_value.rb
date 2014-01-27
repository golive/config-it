require 'coercible'

class ConfigIt::AttributeValue

  def initialize(value, type = nil)
    @type = type
    @value = coerced_value(type, value)
  end

  def value
    @value
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
    if type
      Coercible::Coercer.new[value.class].send("to_#{type}", value)
    else
      value
    end
  end
end
