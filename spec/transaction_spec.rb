require File.dirname(__FILE__) + '/spec_helper'

class BOTest1 < RedisMapper::Base
  field 'field1'
end

class RedisProxy < BasicObject
  attr_reader :calls

  def method_missing(name, *args)
    (@calls ||= []) << name
    ::Redis.current.send name, *args
  end
end

describe RedisMapper::BasicOperations do
  before(:all) do
    module RedisMapper
      remove_const :R
      R = RedisProxy.new
    end
  end

  after(:all) do
    module RedisMapper
      remove_const :R
      R = ::Redis.current
    end
  end

  it 'uses transactions to create records' do
    o = BOTest1.create 'field1' => 'test_value'
    RedisMapper::R.calls.first.should == :multi
    RedisMapper::R.calls.last.should == :exec
  end

  it 'uses transactions to recreate records'
  it 'uses transactions to delete records'
  it 'it cancels transaction on error'
end
