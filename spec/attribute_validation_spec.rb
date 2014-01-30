require 'spec_helper'

describe ConfigIt do

  context 'activemodel validations' do

    before :all do
      class Test
        include ConfigIt
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
      class Test
        include ConfigIt
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
      class Parent
        include ConfigIt
        attribute :attr1
        group :child
      end

      class Parent::Child
        include ConfigIt
        attribute :attr2
        validates_presence_of :attr2
      end
    end

    subject { Parent.new }

    it 'should not be valid', :wip => true do
      subject.should_not be_valid
    end

    after(:all) do
      Parent.send(:remove_const, :Child)
      Object.send(:remove_const, :Parent)
    end
  end

  context 'errors' do
    before :all do
      class Parent
        include ConfigIt
        attribute :attr1
        group :child
      end

      class Parent::Child
        include ConfigIt
        attribute :attr2
        validates_presence_of :attr2
      end

      class Parent::Child2
        include ConfigIt
        attribute :attr3
        validates_presence_of :attr3
      end

      class Parent::Child::GrandChild
        include ConfigIt
        attribute :attr4
        validates_presence_of :attr4
      end
    end

    subject { Parent.new }

    it 'has errors on group attribute' do
      subject.should have(1).errors_on(:child)
    end

    it 'has errors on multiple group attributes' do
      Parent.group :child2
      subject.should have(1).error_on(:child)
      subject.should have(1).error_on(:child2)
    end

    it 'has errors on 2nd level attribute' do
      Parent::Child.group :grand_child
      subject.child.attr2 = 1
      subject.should have(1).error_on(:child)
      subject.child.should have(1).error_on(:grand_child)
    end

    after(:all) do
      Parent::Child.send(:remove_const, :GrandChild)
      Parent.send(:remove_const, :Child)
      Parent.send(:remove_const, :Child2)
      Object.send(:remove_const, :Parent)
    end
  end

end
