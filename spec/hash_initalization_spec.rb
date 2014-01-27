require 'spec_helper'

describe ConfigIt do

  context 'no groups' do
    before :all do

      class Test < ConfigIt
        attribute :attr1
        attribute :attr2, default: 2
        attribute :attr3
        attribute :attr4, default: 4
      end

    end

    it 'works with symbols as keys' do
      Test.new(:attr1 => 1).attr1.should == 1
    end

    it 'works with strings as keys' do
      Test.new('attr1' => 1).attr1.should == 1
    end

    subject { Test.new(:attr1 => 1, :attr2 => 3, :attr5 => 10) }

    it 'set value' do
      subject.attr1.should == 1
    end

    it 'overrides defaults' do
      subject.attr2.should == 3
    end

    it 'returns nil if attributes not set with hash and no default value set' do
      subject.attr3.should == nil
    end

    it 'returns default values if attributes not set with hash' do
      subject.attr4.should == 4
    end

    it 'ignores attributes not defined' do
      expect { subject.attr5 }.to raise_exception
    end

    it 'to_hash returns all attributes' do
      subject.to_hash.should == {attr1: 1, attr2: 3, attr3: nil, attr4: 4}
    end

    after(:all) { Object.send(:remove_const, :Test) }
  end

  context 'with groups' do
    before :all do

      class Parent < ConfigIt
        attribute :attr1
        group :child
      end

      class Parent::Child < ConfigIt
        attribute :attr2, default: 2
        attribute :attr3
        attribute :attr4, default: 4
      end

    end

    subject { Parent.new(:attr1 => 1, :child => {:attr2 => 3, :attr5 => 10}) }

    it 'values of first level' do
      subject.attr1.should == 1
    end

    it 'values of second level' do
      subject.child.attr2.should == 3
      subject.child.attr3.should == nil
      subject.child.attr4.should == 4
    end

    it 'ignores attributes not defined' do
      expect { subject.child.attr5 }.to raise_exception
    end

    it 'to_hash returns all attributes' do
      subject.to_hash.should == {attr1: 1, child: {attr2: 3, attr3: nil, attr4: 4}}
    end

    after(:all) do
      Parent.send(:remove_const, :Child)
      Object.send(:remove_const, :Parent)
    end
  end

  context 'multilevel' do
    before :all do

      class Parent < ConfigIt
        attribute :attr1
        group :child
      end

      class Parent::Child < ConfigIt
        attribute :attr2
        group :grand_child
      end

      class Parent::Child::GrandChild < ConfigIt
        attribute :attr3
      end
    end

    subject { Parent.new(:attr1 => 1, :child => {:attr2 => 2, :grand_child => {:attr3 => 3}}) }

    it 'to_hash returns all attributes' do
      subject.to_hash.should == {attr1: 1, child: {attr2: 2, grand_child: {attr3: 3}}}
    end

    after(:all) do
      Parent::Child.send(:remove_const, :GrandChild)
      Parent.send(:remove_const, :Child)
      Object.send(:remove_const, :Parent)
    end
  end

end
