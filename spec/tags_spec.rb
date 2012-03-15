require File.dirname(__FILE__) + '/spec_helper'


class TagsTest < RedisMapper::Base
  field 'field1'
  has_tags :hohoho
end

describe RedisMapper::Tag do
  it 'creates field for tags collection' do
    o = TagsTest.new
    o.field1 = 'test_value'
    o.hohoho = ['tag1', 'tag2', 'tag3']
    o.save
    TagsTest.get(o.id).hohoho.should == ['tag1', 'tag2', 'tag3']
  end

  it 'updates indexed collections on save and delete' do
    o = TagsTest.new 'field1' => 'test_value'
    o.hohoho = ["test_index1", "test_index2"]
    r.sismember("test_index1", o.id).should == false
    r.sismember("test_index2", o.id).should == false
    o.save
    r.sismember("test_index1", o.id).should == true
    r.sismember("test_index2", o.id).should == true
    o.delete
    r.sismember("test_index1", o.id).should == false
    r.sismember("test_index2", o.id).should == false
  end
end