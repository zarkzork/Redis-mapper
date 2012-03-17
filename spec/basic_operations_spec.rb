require File.dirname(__FILE__) + '/spec_helper'

class BOTest1 < RedisMapper::Base
  field 'field1'
end

describe RedisMapper::BasicOperations do
  it 'adds type when saving' do
    o = BOTest1.new 'field1' => 'test_value'
    o.hash['type'].should == nil
    o.create
    o.hash['type'].should == "BOTest1"
  end
  
  it 'adds id when saving' do
    o = BOTest1.new 'field1' => 'test_value'
    o.hash['id'].should == nil
    o.create
    o.hash['id'].should_not == nil
  end
  
  it 'stores attributes' do
    o = BOTest1.new 'field1' => 'test_value'
    o.create
    BOTest1.get(o.id).field1.should == 'test_value'
  end
  
  it 'removes object on delete' do
    o = BOTest1.create 'field1' => 'test_value'
    id = o.id
    o.delete
    BOTest1.get(id).should == nil
  end

  it 'reads with proper type using base class'  do
    o = BOTest1.create 'field1' => 'test_value'
    RedisMapper::Base.get(o.id).is_a?(BOTest1).should == true
  end

  it 'raises exception on attempt to create existing object' do
    expect {
      o = BOTest1.create 'field1' => 'test_value'
      o.field1 = 'bar'
      o.create
    }.to raise_error
  end

  it 'recreates record' do
    o = BOTest1.create 'field1' => 'test_value'
    old_id = o.id
    o.field1 = 'bar'
    o.recreate
    o.id.should_not == old_id
    BOTest1.get(old_id).should == nil
    BOTest1.get(o.id).field1.should == 'bar'
  end

  it 'users transactions to create, delete and recreate records'
  
  
end
