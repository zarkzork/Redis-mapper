require File.dirname(__FILE__) + '/spec_helper'

describe RedisMapper::Fields do
  before(:each) do
    #flush redis db
  end

  it 'responds to id'
  it 'adds type when saving'
  it 'adds id when saving'
  it 'serializes model' # do we need this?
  it 'saves using key_for'
  it 'reads with proper type using base class'
  it 'has save callbacks'
  
end
