class ConfigIt::AttributeValue

  def initialize(value, default_value = nil)
    @value = value
  end

  def value
    @value
  end

  def value=(value)
    @value = value
  end

  def to_hash
    value
  end
end
