require 'json'

module RedisMapper
  module BasicOperations

    def id
      return self.hash['id'] if self.hash.has_key? "id"      
      add_id
    end

    def create
      run_callbacks :precreate
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
      unless self.hash.has_key? 'type'
        self.hash['type'] = self.class.name
      end
    end

    def add_id
      self.hash['id'] = generate_key unless self.hash.has_key? 'id'
    end

    def generate_key
      key_for(digest(self.hash.to_json))
    end

    # Overwrite this method to change digest mechanism.
    def digest(s)
      Digest::MD5.hexdigest(s)    
    end

    def self.included(o)
      o.extend ClassMethods
    end
    
    module ClassMethods
      
      def get(id)
        hash = R.get(id)
        parse(hash) if hash
      end

      def parse(hash)
        new parse_hash(hash)
      end

      def create(hash)
        o = new(hash)
        o.create
        o
      end

      private

      def parse_hash(hash)
        hash && JSON.parse(hash)
      end
    end
  end
end
