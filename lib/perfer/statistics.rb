module Perfer
  class Statistics
    include Math
    CONFIDENCE_LEVEL = 0.95
    ALPHA = 1.0 - CONFIDENCE_LEVEL

    # Student's t quantiles is used as n is small (= number of measurements)
    # Indexed by: probability, degrees of freedom
    T_QUANTILES = {
      0.975 => [
        nil,
        12.71, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228, #  1-10
        2.201, 2.179, 2.160, 2.145, 2.131, 2.120, 2.110, 2.101, 2.093, 2.086, # 11-20
        2.080, 2.074, 2.069, 2.064, 2.060, 2.056, 2.052, 2.048, 2.045, 2.042, # 21-30
        2.040, 2.037, 2.035, 2.032, 2.030, 2.028, 2.026, 2.024, 2.023, 2.021  # 31-40
      ]
    }
    { 50 => 2.009, 60 => 2.000,  70 => 1.994,
      80 => 1.990, 90 => 1.987, 100 => 1.984 }.each_pair { |n, value|
      T_QUANTILES[0.975][n] = value
    }

    def self.t_quantile(p, degrees_of_freedom)
      if degrees_of_freedom <= 40
        T_QUANTILES[p][degrees_of_freedom]
      elsif degrees_of_freedom <= 100
        T_QUANTILES[p][degrees_of_freedom.round(-1)]
      else
        1.960
      end
    end

    def initialize(sample)
      @sample = sample
    end

    def size
      @sample.size
    end

    def mean
      @mean ||= @sample.inject(0.0) { |sum, i| sum + i } / size
    end

    def sample_variance
      mean = mean()
      @sample.inject(0.0) { |var, i|
        d = i - mean
        var + d*d
      } / (size - 1) # unbiased sample variance
    end

    def sample_standard_deviation
      sqrt(sample_variance)
    end

    def sample_standard_error
      sample_standard_deviation / sqrt(size)
    end

    def margin_of_error
      (Statistics.t_quantile(1.0 - ALPHA/2, size-1) * sample_standard_error) / mean
    end

    def maximum_absolute_deviation
      @sample.map { |v| (v - mean).abs }.max / mean
    end
  end
end
