require 'spec_helper'

describe ConfigIt do

  context '#group' do
    before :all do

      class Parent
        include ConfigIt
        attribute :attr1
        group :child
      end

      class Parent::Child
        include ConfigIt
        attribute :attr2
        attribute :attr3, default: 2
      end

    end

    subject { Parent.new }

    it 'responds to group attribute' do
      should respond_to :child
    end

    it 'returns a object of group' do
      subject.child.should be_kind_of Parent::Child
    end

    it 'navigates to nested attributes' do
      subject.child.should respond_to :attr2
    end

    it 'sets nested attibutes' do
      subject.child.attr2 = 1
      subject.child.attr2.should == 1
    end

    it 'returns default nested attribute values' do
      subject.child.attr3.should == 2
    end

    it 'allows to override group configuration' do
      class Test
        include ConfigIt
        attribute :attr2
      end

      Parent.group :child, class_name: "Test"
      Parent.new.child.should be_kind_of Test
    end

    after(:all) do
      Parent.send(:remove_const, :Child)
      Object.send(:remove_const, :Parent)
      Object.send(:remove_const, :Test)
    end
  end

  context 'multilevel' do

    before :all do

      class Parent
        include ConfigIt
        group :child
      end

      class Parent::Child
        include ConfigIt
        group :grand_child
      end

      class Parent::Child::GrandChild
        include ConfigIt
        attribute :attr3, default: 1
      end
    end

    it 'get the class if _ present' do
      expect { Parent.new }.to_not raise_exception
    end

    it 'navigates to last level' do

    end

    after(:all) do
      Parent::Child.send(:remove_const, :GrandChild)
      Parent.send(:remove_const, :Child)
      Object.send(:remove_const, :Parent)
    end
  end

  context '#group with specific class' do
    before :all do

      class Parent
        include ConfigIt
        attribute :attr1
        group :child, class_name: "Child"
      end

      class Child
        include ConfigIt
        attribute :attr2
        attribute :attr3, default: 2
      end

      class Parent2
        include ConfigIt
        group :child2
      end

      class Parent3
        include ConfigIt
        group :child3, class_name: "Child3"
      end
    end

    subject { Parent.new }

    it 'returns a object of group' do
      subject.child.should be_kind_of Child
    end

    it "raises exception if group class doesn't exist" do
      expect { Parent2.new }.to raise_exception(ConfigIt::ConfigError, /Child2/)
    end

    it "raises exception if group class doesn't exist with specific class" do
      expect { Parent3.new }.to raise_exception(ConfigIt::ConfigError, /Child3/)
    end

    after(:all) do
      Object.send(:remove_const, :Parent)
      Object.send(:remove_const, :Child)
    end
  end
end
