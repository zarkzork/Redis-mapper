require 'simplecov'

SimpleCov.start do
  add_filter '/development/'
end

require './lib/redis_mapper'

def r
  Redis.current
end

RSpec.configure do |c|
  c.before(:each) do
    #flush redis db
    r.flushall
  end
end
