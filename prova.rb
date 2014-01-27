class A
  class << self; attr_reader :attribute_names end
  @attribute_names = []

  def self.b
    @attribute_names << 1
  end
end
