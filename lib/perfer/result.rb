require 'forwardable'

module Perfer
  # A result for a particular job run
  class Result
    extend Forwardable

    attr_reader :metadata, :data
    def initialize(metadata)
      @metadata = metadata.dup
      @data = []
    end

    def_instance_delegators :@data,
      :<<, :size, :length, :each

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
      @data.map { |result| result[field] }
    end
  end
end
