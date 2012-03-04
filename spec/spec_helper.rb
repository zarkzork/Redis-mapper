require './lib/redis_mapper'

def r
  Redis.current
end

r.select 13

unless r.dbsize == 0
  puts "Database number 13 is used for testing."
  puts "It should be empty"
  exit 1
end
