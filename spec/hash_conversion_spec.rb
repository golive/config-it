require 'spec_helper'

describe ConfigIt, '#to_hash' do

  context 'simple attribute' do
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

    after(:all) { Object.send(:remove_const, :Test) }
  end

  context 'default values' do
    before :all do

      class Test < ConfigIt
        attribute :attr1, default: 1
      end

    end

    subject { Test.new }

    it 'converts to hash with default value' do
      subject.to_hash.should == {:attr1 => 1}
    end

    after(:all) { Object.send(:remove_const, :Test) }
  end

  context 'changed values' do
    before :all do

      class Test < ConfigIt
        attribute :attr1, default: 1
      end

    end

    subject { Test.new }

    it 'converts to hash with default value' do
      subject.attr1 = 2
      subject.to_hash.should == {:attr1 => 2}
    end

    after(:all) { Object.send(:remove_const, :Test) }
  end

  context 'group' do
    before :all do

      class Parent < ConfigIt
        attribute :attr1
        group :child
      end

      class Parent::Child < ConfigIt
        attribute :attr2
        attribute :attr3, default: 2
      end

    end

    subject { Parent.new }

    it 'converts to hash with default value' do
      subject.to_hash.should == {:attr1 => nil, :child => {:attr2 => nil, :attr3 => 2}}
    end

    it 'changing values' do
      subject.attr1 = 1
      subject.child.attr2 = 3
      subject.child.attr3 = 4
      subject.to_hash.should == {:attr1 => 1, :child => {:attr2 => 3, :attr3 => 4}}
    end

    after(:all) do
      Parent.send(:remove_const, :Child)
      Object.send(:remove_const, :Parent)
    end
  end
end

