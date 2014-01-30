require 'spec_helper'

describe ConfigIt::AttributeValue do

  it 'save value' do
    av = ConfigIt::AttributeValue.new('value')
    av.value.should == 'value'
  end

  it 'allow to override value' do
    av = ConfigIt::AttributeValue.new('value')
    av.value = 'copy_value'
    av.value.should == 'copy_value'
  end

  context 'default values' do
    it 'stores default values' do
      av = ConfigIt::AttributeValue.new(nil, default: 1)
      av.value.should == 1
    end

    it 'reverts to default value if null value' do
      av = ConfigIt::AttributeValue.new(1, default: 2)
      av.value = nil
      av.value.should == 2
    end
  end

  context 'coerce values' do
    it 'not coerces non incompatible value' do
      av = ConfigIt::AttributeValue.new(1, type: :date)
      av.value.should == 1
    end

    it "doesn't coerce nil value" do
      av = ConfigIt::AttributeValue.new(nil, type: :date)
      av.value.should be_nil
    end

    it 'coerces to boolean' do
      [1, "1", "yes", "true"].each do |v|
        av = ConfigIt::AttributeValue.new(v, type: :boolean)
        av.value.should be_true
      end
      [0, "0", "no", "false"].each do |v|
        av = ConfigIt::AttributeValue.new(v, type: :boolean)
        av.value.should be_false
      end
    end

    it 'coerces to float' do
      [1, "1", 1.0].each do |v|
        av = ConfigIt::AttributeValue.new(v, type: :float)
        av.value.should == 1.0
      end
    end

    it 'coerces to integer' do
      [1, "1", 1.0].each do |v|
        av = ConfigIt::AttributeValue.new(v, type: :float)
        av.value.should == 1
      end
    end

    it 'coerces upon assingation' do
      av = ConfigIt::AttributeValue.new(1, type: :boolean)
      av.value = 0
      av.value.should be_false
    end

    it 'coerces each value of an array' do
      av = ConfigIt::AttributeValue.new(["1", "2", 3], type: :integer)
      av.value.should == [1,2,3]
    end
  end

end
