module RedisMapper
  module Tag

    def self.included(o)
      o.extend ClassMethods
    end

    module ClassMethods

      def has_tags(name = :tags)
        name = name.to_sym
        field name

        tagsList = "#{self.name}.tags"

        callback :postcreate do |o|
          (o.send(name) || []).each do |t|
            key = o.digest t 
            R.sadd(key, o.id)

            R.zincrby tagsList, 1, t
          end
        end
 
        callback :predelete do |o|
          (o.send(name) || []).each do |t|
            key = o.digest t 
            R.srem(key, o.id)

            R.zincrby tagsList, -1, t
          end
        end
      end
    end
  end
end
