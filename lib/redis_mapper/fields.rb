module RedisMapper
  module Fields

    def fields
      self.class.fields
    end

    def self.included(o)
      o.extend ClassMethods
    end

    module ClassMethods

      def fields
        @fields ||= []
      end
      

      def field(*args)
        self.fields.concat args
        args.each { |f| define_field f }
      end

      private

      def define_field(m)
        define_method(m){ self.hash[m] }
        define_method("#{m}="){ |v| self.hash[m] = v }
      end
      
    end
    
  end
end
