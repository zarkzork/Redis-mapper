module RedisMapper
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
      hashes = R.sort @key, :get => "*", :limit => [@first, @last], :by => 'nosort'
      hashes.map { |h| instantiate(h) }
    end

    def instantiate(hash)
      Base.parse(hash)
    end
  end
end
