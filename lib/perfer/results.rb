require 'forwardable'

module Perfer
  # A set of results for a particular job
  class Results
    extend Forwardable

    def initialize
      @results = []
    end

    delegate [:<<, :size, :length, :to_a, :each, :first] => :@results

    def aggregate
      stats = Statistics.new(on(:real))
      mean, stddev = stats.mean, stats.stddev
      {
        :mean => mean,
        :stddev => stddev,
        :stddev3 => 3*stddev,
        :percent_incertitude => (3*stddev / mean * 100)
      }
    end

    def on(field)
      @results.map { |result| result[field] }
    end
  end
end
