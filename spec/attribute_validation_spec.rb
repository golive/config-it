require 'spec_helper'

describe ConfigIt do

  context 'activemodel validations' do

    before :all do
      class Test < ConfigIt
      end
    end

    it 'should respond to validation methods' do
      Test.should respond_to :validates_presence_of
    end

    it "doesn't have errors" do
      Test.new.errors.should be_empty
    end

    after(:all) { Object.send(:remove_const, :Test) }
  end

  context 'validation of attributes' do
    before :all do
      class Test < ConfigIt
        attribute :attr1

        validates_presence_of :attr1
      end
    end

    subject { Test.new }

    it 'responds to valid?' do
      subject.should respond_to :valid?
    end

    it 'should not be valid' do
      subject.should_not be_valid
    end

    it 'validates' do
      subject.attr1 = 1
      subject.should be_valid
    end

    after(:all) { Object.send(:remove_const, :Test) }
  end

  context 'validation of groups' do
    before :all do
      class Parent < ConfigIt
        attribute :attr1
        group :child
      end

      class Parent::Child < ConfigIt
        attribute :attr2
        validates_presence_of :attr2
      end
    end

    subject { Parent.new }

    it 'should not be valid' do
      subject.should_not be_valid
    end

    it 'validates with attribute context' do
      subject.should be_valid(:attr1)
    end

    it 'validates if inexistent context' do
      subject.child.attr2 = 1
      subject.should be_valid(:attr2)
    end

    it 'valdates with group context' do
      Parent.validates_presence_of :attr1
      subject.child.attr2 = 1
      subject.should_not be_valid
      subject.should be_valid(:child)
      subject.should_not be_valid(:attr1)
    end

    after(:all) do
      Parent.send(:remove_const, :Child)
      Object.send(:remove_const, :Parent)
    end
  end
end
