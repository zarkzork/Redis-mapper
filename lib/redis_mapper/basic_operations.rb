module RedisMapper
  module BasicOperations

    def id
      return self.hash.id if has_key? "id"      
      add_id
    end

    def save
      _run_save_callbacks do
        add_type
        R.set key_for(id), serialize
      end
    end

    def serialize
      self.hash.to_json
    end
    
    private

    def add_type
      unless self.hash.has_key? 'type'
        self.hash['type'] = self.class.name
      end
    end

    def add_id
      self.hash['id'] = generate_key unless has_key? 'id'
    end

    def generate_key
      digest self.hash.to_json
    end

    def digest(s)
      Digest::MD5.hexdigest(s)    
    end

    def self.included(o)
      o.extend ActiveModel::Callbacks    
      o.extend ClassMethods
    end
    
    module ClassMethods

      def self.extended(o)
        o.define_model_callbacks :save
      end
      
      def get(id)
        hash = parse R.get(key_for(id))
        new(hash)
      end

      def create(hash)
        o = new(hash)
        o.save
        o
      end

      private

      def parse(hash)
        JSON.parse hash
      end
    end
  end
end
