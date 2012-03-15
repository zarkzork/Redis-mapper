require File.dirname(__FILE__) + '/spec_helper'

class BOTest1 < RedisMapper::Base
  field 'field1'
end

describe RedisMapper::BasicOperations do
  it 'adds type when saving' do
    o = BOTest1.new 'field1' => 'test_value'
    o.hash['type'].should == nil
    o.save
    o.hash['type'].should == "BOTest1"
  end
  
  it 'adds id when saving' do
    o = BOTest1.new 'field1' => 'test_value'
    o.hash['id'].should == nil
    o.save
    o.hash['id'].should_not == nil
  end
  
  it 'stores attributes' do
    o = BOTest1.new 'field1' => 'test_value'
    o.save
    o.id.should_not == nil
    BOTest1.get(o.id).field1.should == 'test_value'
  end
  
  it 'removes object on delete' do
    o = BOTest1.create 'field1' => 'test_value'
    id = o.id
    o.delete
    BOTest1.get(id).field1.should == nil
  end

  it 'reads with proper type using base class'  do
    o = BOTest1.create 'field1' => 'test_value'
    RedisMapper::Base.get(o.id).is_a?(BOTest1).should == true
  end
  
end
