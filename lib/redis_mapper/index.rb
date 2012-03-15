module RedisMapper

  # todo create index
  # todo add :of property to index method (add save callback to
  # class :of
  #
  # use hooks for saving or deleting information from indexes
  # api should look something like
  #
  # class Test < Base
  #   index :valid_items { |o| o.valid? }
  # end
  #
  # if retuned value is array, then first element array is used as value
  # second as score.
  # TODO do we need provide methods for getting maximum score in lambda
  # TODO do we need methods to put element into index from code
  # cache sets
  module Index

    def add_to_index(name, score)
      R.zadd name, score, self.id
    end

    def remove_from_index(name)
      R.zrem name, self.id
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

      def collection_accessor(collection_name)
        define_singleton_method(collection_name) do
          Zset.new(collection_name)
        end          
      end

      def add_after_save_hook(name, &block)
        callback :postsave do |o|
          value, score = block.call(o)
          if value
            o.add_to_index name, (score || 0)
          else
            o.remove_from_index name
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
        @zset ||= fetch_set!
      end

      def [](index)
        self.zset[index]
      end

      def each(&block)
        self.zset.each(&block)
      end

      def to_a
        self.zset
      end

      def first
        self.zset.first
      end

      def last
        self.zset.last
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
        hashes.map { |h| instantiate(h) }
      end

      def instantiate(hash)
        Base.parse(hash)
      end
    end
  end
end
