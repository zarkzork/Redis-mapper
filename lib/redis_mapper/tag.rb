module RedisMapper
  module Tag

    def self.included(o)
      o.extend ClassMethods
    end

    module ClassMethods

      def has_tags(name = :tag)
        name = name.to_sym
        field name
        list_key = tags_list_key(name)

        callback :postcreate do |o|
          (o.send(name) || []).each do |t|
            key = o.digest t
            R.sadd(key, o.id)
            R.zincrby list_key, 1, t
          end
        end

        callback :predelete do |o|
          (o.send(name) || []).each do |t|
            key = o.digest t
            R.srem(key, o.id)
            result = R.zincrby list_key, -1, t
            R.zrem list_key, t if result == '0'
          end
        end

        create_tag_accessor(name)
        create_tags_accessor(name)
      end

      private

      def create_tag_accessor(name)
        define_singleton_method("for_#{name}") do |tag|
          Zset.new(self.digest(tag))
        end
      end

      def create_tags_accessor(name)
        define_singleton_method("#{name}s") do
          SimpleZset.new(tags_list_key(name)).reverse
        end
      end

      def tags_list_key(name)
        "#{self.name}.#{name}s"
      end
    end
  end
end
