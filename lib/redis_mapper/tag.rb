module RedisMapper
  module Tag

    def self.included(o)
      o.extend ClassMethods
    end

    module ClassMethods

      def has_tags(name = :tags)
        # FIXME: what if tags are not redis safe strings?
        
        name = name.to_sym
        field name

        callback :postcreate do |o|
          (o.send(name) || []).each do |t|
            key = (t.respond_to? :id) ? t.id : t
            R.sadd(key, o.id)
          end
        end
 
        callback :predelete do |o|
          (o.send(name) || []).each do |t|
            key = (t.respond_to? :id) ? t.id : t
            R.srem(key, o.id)
          end
        end
      end
    end
  end
end
