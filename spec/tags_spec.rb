#encoding: utf-8
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
    o.create
    TagsTest.get(o.id).hohoho.should == ['tag1', 'tag2', 'tag3']
  end

  it 'works with utf-8 tags' do
    o = TagsTest.new 'field1' => 'test_value'
    o.hohoho = ['мимими']
    o.create
    TagsTest.get(o.id).hohoho.should == ['мимими']
  end

  it 'updates tags on create and delete' do
    o = TagsTest.new 'field1' => 'test_value'
    o.hohoho = ["tag1", "tag2"]
    r.sismember(o.digest("tag1"), o.id).should == false
    r.sismember(o.digest("tag2"), o.id).should == false
    o.create
    r.sismember(o.digest("tag1"), o.id).should == true
    r.sismember(o.digest("tag2"), o.id).should == true
    o.delete
    r.sismember(o.digest("tag1"), o.id).should == false
    r.sismember(o.digest("tag2"), o.id).should == false
  end

  it 'allows to access collection' do
    o = TagsTest.new 'field1' => 'test_value'
    o.hohoho = ["tag1", "tag2"]
    o.create
    TagsTest.for_hohoho('tag1').to_a.map(&:id).should == [o.id]
  end

  it 'stores tags usage' do
    o1 = TagsTest.new 'field1' => 'test_value'
    o1.hohoho = ["tag10", "tag20", "мимими"]
    o2 = TagsTest.new 'field2' => 'test_value'
    o2.hohoho = ["tag10"]
    r.zscore("TagsTest.hohohos", "tag10").should == nil
    r.zscore("TagsTest.hohohos", "tag20").should == nil
    r.zscore("TagsTest.hohohos", "мимими").should == nil
    o1.create
    o2.create
    r.zscore("TagsTest.hohohos", "tag10").should == "2"
    r.zscore("TagsTest.hohohos", "tag20").should == "1"
    r.zscore("TagsTest.hohohos", "мимими").should == "1"
    o1.delete
    o2.delete
    r.zscore("TagsTest.hohohos", "tag10").should == nil
    r.zscore("TagsTest.hohohos", "tag20").should == nil
    r.zscore("TagsTest.hohohos", "мимими").should == nil
  end

  it 'allows to access tags' do
    o1 = TagsTest.new 'field1' => 'test_value1'
    o1.hohoho = ["tag1", "tag2", "tag3"]
    o1.create
    o2 = TagsTest.new 'field1' => 'test_value2'
    o2.hohoho = ["tag1", "tag2"]
    o2.create
    o3 = TagsTest.new 'field2' => 'test_value3'
    o3.hohoho = ["tag1"]
    o3.create

    TagsTest.hohohos.to_a.should == ["tag1", "tag2", "tag3"]
    o1.delete
    o2.delete
    TagsTest.hohohos.to_a.should == ["tag1"]

  end

  it 'counts removes stale tags from index' do
    o1 = TagsTest.new 'field1' => 'test_value'
    o1.hohoho = ["tag1"]
    o1.create
    o1.delete
    o2 = TagsTest.new 'field1' => 'test_value'
    o2.hohoho = ["tag2"]
    o2.create
    TagsTest.hohohos.to_a.should == ['tag2']
  end

end
