module Perfer
  class Statistics
    def initialize(sample)
      @sample = sample
    end

    def size
      @sample.size
    end

    def mean
      @mean ||= @sample.inject(0.0) { |sum, i| sum + i } / size
    end

    def median
      @median ||= begin
        sorted = @sample.sort
        if size.odd?
          sorted[size/2]
        else
          (sorted[size/2-1] + sorted[size/2]) / 2.0
        end
      end
    end

    def variance
      mean = mean()
      @sample.inject(0.0) { |var, i|
        d = i - mean
        var + d*d
      } / (size - 1) # unbiased sample variance
    end

    def standard_deviation
      Math.sqrt(variance)
    end

    def coefficient_of_variation
      standard_deviation / mean
    end

    def standard_error
      standard_deviation / Math.sqrt(size)
    end

    def mean_absolute_deviation
      @sample.inject(0.0) { |dev, i| dev + (i - mean).abs } / size
    end

    def median_absolute_deviation
      Statistics.new(@sample.map { |i| (i - median).abs }).median
    end

    def maximum_absolute_deviation
      @sample.map { |v| (v - mean).abs }.max
    end
  end
end
