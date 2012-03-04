module RedisMapper

  # todo create index
  # todo add :of property to index method (add save callback to
  # class :of
  #
  # use hooks for saving or deleting information from indexes
  # api should look something like
  #
  # class Test < Base
  #   index :valid_items { |i| item.valid? }
  # end
  #
  # if retuned value is array, then first element array is used as value
  # second as score.
  # todo do we need provide methods for getting maximum score in lambda
  # todo do we need methods to put element into index from code
  # cache sets
  module Index

    def add_to_index(name, score)
      R.zadd key_for(name), score, self.id
    end

    def remove_from_index(name)
      R.zrem key_for(name)    
    end
    
    def self.included(o)
      o.extend ClassMethods
    end

    module ClassMethods

      def indexes
        @indexes ||= {}      
      end

      def index(name, &block)
        indexes[name] = block
        add_after_save_hook(name, &block)
        collection_accessor(name)
      end

      private

      def collection_accessor(name)
        v_name = "@__#{name}"
        define_method name do
          #todo better way to write this
          instance_variable_get(v_name) or
            instance_variable_set v_name,  Zset.new(key_for(name))
        end
      end

      def add_after_save_hook(name, &block)
        after_save do
          value, score = block.call(self)
          if value
            score ||= 0 
            add_to_index name, score
          else
            remove_from_index name
          end
        end        
      end
      
    end

    class Zset

      include Enumerable

      def initialize(key, first = 0, last = -1)
        @key, @first, @last = key, first, last
      end

      def zset
        @zset ||= fetch_set
      end

      def [](index)
        zset[index]
      end

      def each(&block)
        zset.each(&block)
      end

      def first
        zset.first
      end

      def last
        zset.last
      end

      def page(page = 1, per_page = 10)
        first = per_page * page
        last = first + per_page
        self.class.new(@key, first, last)
      end

      def reload!
        fetch_set!
      end

      private
      
      def fetch_set!
        hashes = R.sort @key, :get => "*", :limit => [@first, @last]
        hashes.map { |h| instantiate h }
      end

      def instantiate(hash)
        Base.new(hash)
      end
      
    end
  end
end
