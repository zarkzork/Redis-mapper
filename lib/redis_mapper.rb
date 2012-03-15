require 'redis'

module RedisMapper

  autoload :Index, 'redis_mapper/index'
  autoload :BasicOperations, 'redis_mapper/basic_operations'
  autoload :Fields, 'redis_mapper/fields'
  autoload :Base, 'redis_mapper/base'
  autoload :Tag, 'redis_mapper/tag'
  
  R = Redis.current

end
