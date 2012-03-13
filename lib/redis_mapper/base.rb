module RedisMapper  
  class Base
    # add immutability?
    # todo add equality

    include Fields
    include BasicOperations
    include Index

    attr_writer :hash

    def hash
      @hash ||= {}
    end

    def initialize(hash = {})
      self.hash = hash
    end

    def key_for(v)
      self.class.key_for v
    end

    def run_callbacks (name)
      ((self.class.callbacks ||= {}) [name] ||= []).each do |c|
        self.instance_eval &c
      end
    end

    class << self

      attr :classes
      attr_reader :callbacks
      
      def inherited(c)
        (@classes ||= {})[c.name] = c
      end

      def new(*args)
        if self == Base && cls_name = type_from_args(args)
          raise "Cannot find #{cls_name} class" unless cls = classes[cls_name]
          cls.new(*args)
        else
          super
        end
      end

      def callback (name, &block)
        (@callbacks ||= {}) [name] ||= []
        @callbacks [name].push(block)
      end

      def type_from_args(args)
        h = args.first and h.instance_of?(Hash) and h['type']
      end
      
      def key_for(v)
        "#{self.name}##{v}"
      end
    end
  end
end
