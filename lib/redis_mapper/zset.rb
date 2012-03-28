module RedisMapper
  class BaseZset

    include Enumerable

    def initialize(key, first = 0, last = -1, reverse = false)
      @key, @first, @last, @reverse = key, first, last, reverse
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

    def reverse
      self.class.new(@key, @first, @last, !@reverse)
    end

    protected

    def fetch_set!
      raise NotImplementedError
    end

    private

    def instantiate(hash)
      Base.parse(hash)
    end
  end

  class Zset < BaseZset
    protected

    def fetch_set!
      order = @reverse ? 'nosort DESC' : 'nosort'
      hashes = R.sort @key, :get => "*", :limit => [@first, @last], :by => order
      hashes.map { |h| instantiate(h) }
    end
  end

  class SimpleZset < BaseZset
    protected

    def fetch_set!
      command = @reverse ? :zrevrange : :zrange
      R.send command, @key, @first, @last
    end
  end
end
