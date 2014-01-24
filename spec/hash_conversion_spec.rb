require 'spec_helper'

describe ConfigIt, '#to_hash' do

  before :all do

    class Test < ConfigIt
      attribute :attr1
    end

  end

  subject { Test.new }

  it 'should respond to to_hash' do
    should respond_to :to_hash
  end

  it 'converts to hash' do
    subject.to_hash.should == {:attr1 => nil}
  end
end

