require File.dirname(__FILE__) + '/spec_helper'

class BaseTest1 < RedisMapper::Base; end
class BaseTest2 < RedisMapper::Base; end
class BaseTest3 < RedisMapper::Base
   field 'field1'

   callback :precreate do |o|
     o.field1 = "callback_write"
   end
end


describe RedisMapper::Base do

  before(:each) do
    @bt1 = BaseTest1.new({})
  end

  it 'creates base object with empty hash' do
    RedisMapper::Base.new
  end

  it "has hash" do
    @bt1.respond_to?(:hash).should be_true
  end

  it 'generates key_for' do
    BaseTest1.key_for('test').should == "BaseTest1#test"
    @bt1.key_for('test').should == "BaseTest1#test"
  end

  it 'defines type of mapped class by hash' do
    o = RedisMapper::Base.new 'type' => 'BaseTest1'
    o.class.should == BaseTest1

    o = BaseTest1.new 'type' => 'BaseTest2'
    o.class.should == BaseTest1

    o = RedisMapper::Base.new 'key' => 'value'
    o.class.should == RedisMapper::Base    
  end

  it 'raise error when type is unknown' do
    expect {
      RedisMapper::Base.new 'type' => 'SomeWeirdType'
    }.to raise_error
  end

   it 'has create callbacks' do
     o = BaseTest3.new 'field1' => 'test_value'
     o.create
     BaseTest3.get(o.id).field1.should == 'callback_write'
   end
end
