require 'spec_helper'

describe ConfigIt, '#group' do

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

  after(:all) do
    Parent.send(:remove_const, :Child)
    Object.send(:remove_const, :Parent)
  end
end
