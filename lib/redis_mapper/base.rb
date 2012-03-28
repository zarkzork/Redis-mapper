module RedisMapper
  class Base
    # add immutability?
    # todo add equality
    # todo check that id is correct on saving

    include Fields
    include BasicOperations
    include Index
    include Tag

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

    def run_callbacks(name)
      return unless self.class.callbacks.is_a?(Hash)
      self.class.callbacks[name].each{ |c| c.call(self) }
    end

    def digest(s)
      self.class.digest(s)
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

      def callback(name, &block)
        @callbacks ||= Hash.new { |hash, key| hash[key] = [] }
        @callbacks[name] << block
      end

      def type_from_args(args)
        h = args.first and h.instance_of?(Hash) and h['type']
      end

      def key_for(v)
        "#{self.name}##{v}"
      end

      def digest(s)
        Digest::MD5.hexdigest(s)
      end
    end
  end
end
