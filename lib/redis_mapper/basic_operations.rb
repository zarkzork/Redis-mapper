require 'json'

module RedisMapper
  module BasicOperations

    def id
      self.hash['id']
    end

    def create
      run_callbacks :precreate
      add_id!
      add_type!
      R.set self.id, serialize
      run_callbacks :postcreate
    end

    def delete
      run_callbacks :predelete
      R.del id
      run_callbacks :postdelete
    end

    def serialize
      self.hash.to_json
    end
    
    private

    def add_type!
      return if self.hash.has_key? 'type'
      self.hash['type'] = self.class.name
    end

    def add_id!
      return if self.hash.has_key? 'id'
      self.hash['id'] = generate_key unless self.hash.has_key? 'id'
    end

    def generate_key
      key_for(digest(self.hash.to_json))
    end

    def self.included(o)
      o.extend ClassMethods
    end
    
    module ClassMethods
      
      def get(id)
        str = R.get(id)
        parse(str) if str
      end

      def parse(str)
        new parse_hash(str)
      end

      def create(hash)
        o = new(hash)
        o.create
        o
      end

      private

      def parse_hash(str)
        str && JSON.parse(str)
      end
    end
  end
end
