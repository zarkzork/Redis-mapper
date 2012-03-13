require File.dirname(__FILE__) + '/spec_helper'

class BOTest1 < RedisMapper::Base
  field 'field1'
  indexes_collection :hohoho
end

class BOTest2 < RedisMapper::Base
  field 'field1'

  callback :presave do
    # TODO ask V why doesn't it work like this
    # field1 = "callback_write"
    send "field1=", "callback_write"
  end
end

describe RedisMapper::BasicOperations do
  before(:each) do
    #flush redis db
    r.flushall
  end
  after(:each) do
    r.flushall
  end

  def check_save
    bot1 = BOTest1.new 'field1' => 'test_value'
    bot1.save
    bot1.id.should_not == nil
    BOTest1.get(bot1.id).field1.should == 'test_value'
    bot1
  end

  it 'responds to id' # O_o'# TODO ask
  it 'adds type when saving' do
    bot1 = BOTest1.new 'field1' => 'test_value'
    bot1.hash['type'].should == nil
    bot1.save
    bot1.hash['type'].should_not == nil
  end
  it 'adds id when saving' do
    bot1 = BOTest1.new 'field1' => 'test_value'
    bot1.hash['id'].should == nil
    bot1.save
    bot1.hash['id'].should_not == nil
  end
  it 'serializes model' # do we need this?
  it 'saves using key_for' do
    check_save
  end
  it 'removes object on delete' do
    bot1 = check_save
    id = bot1.id
    bot1.delete
    BOTest1.get(id).field1.should == nil
  end
  it 'reads with proper type using base class'  # TODO ask
  it 'has save callbacks' do
    bot2 = BOTest2.new 'field1' => 'test_value'
    bot2.save
    BOTest2.get(bot2.id).field1.should == 'callback_write'
  end
  it 'updates indexed collections on save and delete' do
    bot1 = BOTest1.new 'field1' => 'test_value'
    bot1.hohoho = ["test_index1", "test_index2"]
    r.sismember("test_index1", bot1.id).should == false
    r.sismember("test_index2", bot1.id).should == false
    bot1.save
    r.sismember("test_index1", bot1.id).should == true
    r.sismember("test_index2", bot1.id).should == true
    bot1.delete
    r.sismember("test_index1", bot1.id).should == false
    r.sismember("test_index2", bot1.id).should == false
  end
  
end
