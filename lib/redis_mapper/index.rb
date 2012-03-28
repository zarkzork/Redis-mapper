module RedisMapper

  # todo create index
  # todo add :of property to index method (add create callback to
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
        add_after_create_hook(name, &block)
        create_collection_accessor(name)
      end

      private

      def create_collection_accessor(collection_name)
        define_singleton_method(collection_name) do
          Zset.new(collection_name)
        end
      end

      def add_after_create_hook(name, &block)
        callback :postcreate do |o|
          value, score = block.call(o)
          o.add_to_index name, (score || 0) if value
        end
        callback :postdelete do |o|
          value, score = block.call(o)
          o.remove_from_index name # We remove it from index anyway
        end
      end

    end
  end
end
