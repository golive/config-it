require 'spec_helper'

describe ConfigIt, '#attribute' do

  before :all do
    class Test < ConfigIt
      attribute :attr1
      attribute :attr2, default: 3
    end
  end

  subject { Test.new }

  it 'has attributes defined as methods' do
    should respond_to :attr1
  end

  it 'has attribute getter' do
    subject.attr1.should_not be
  end

  it 'has attribute setter' do
    should respond_to "attr1="
  end

  its 'getter retrieves setter value' do
    subject.attr1 = 1
    subject.attr1.should == 1
  end

  it 'overrides values' do
    subject.attr1 = 1
    subject.attr1.should == 1
    subject.attr1 = 2
    subject.attr1.should == 2
  end

  it 'returns default values' do
    subject.attr2.should == 3
  end

  it 'overrides default values' do
    subject.attr2 = 4
    subject.attr2.should == 4
  end

  after(:all) { Object.send(:remove_const, :Test) }
end
