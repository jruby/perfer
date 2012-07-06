module Perfer
  class Statistics
    attr_reader :sample, :size
    def initialize(sample)
      @sample = sample
      @size = sample.size
    end

    def mean
      @mean ||= @sample.inject(0.0) { |sum, i| sum + i } / @size
    end

    def variance
      mean = mean()
      @sample.inject(0.0) { |var, i|
        d = i - mean
        var + d*d
      } / (@size - 1)
    end

    def stddev
      Math.sqrt(variance)
    end
  end
end
