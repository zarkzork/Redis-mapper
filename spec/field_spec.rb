require File.dirname(__FILE__) + '/spec_helper'

class FieldsTest1 < RedisMapper::Base
  field 'field1', 'field2'
  field 'field3'
end

describe RedisMapper::Fields do

  it 'has fields' do
    ft1 = FieldsTest1.new
    %w[field1 field2 field3].each do |f|
      FieldsTest1.fields.member?(f).should == true
      ft1.fields.member?(f).should == true
      ft1.respond_to?(f.to_sym).should == true
    end
  end

  it 'is possible to store and read value from fields' do
    ft1 = FieldsTest1.new 'field2' => 'test_value'
    [nil, 'test_value', nil].should == [ft1.field1, ft1.field2, ft1.field3]
    ft1.field1, ft1.field2, ft1.field3 = '1', '2', '3'
    ['1', '2', '3'].should == [ft1.field1, ft1.field2, ft1.field3]
  end

end
