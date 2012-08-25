module Perfer
  class InputSizeJob < Job
    attr_writer :last_measurement

    DEFAULT_START = 1024
    DEFAULT_GENERATOR = lambda { |n| n * 2 }

    def initialize(session, title, &block)
      super(session, title, &block)
      extra = @session.next_job_metadata
      @start = (extra && extra.delete(:start)) || DEFAULT_START
      @generator = (extra && extra.delete(:generator)) || DEFAULT_GENERATOR
      load_metadata
    end

    def measure(n)
      GC.start
      @block.call(n)
      @last_measurement
    end

    def run
      super
      n = @start
      # find an appropriate maximal n, acts as warm-up
      loop do
        time = measure(n)[:real]
        break if time > minimal_time
        n = @generator.call(n)
      end

      max = n
      n = @start
      loop do
        result = Result.new(@metadata)
        result[:input_size] = n
        number_of_measurements.times do
          result << measure(n)
        end
        @session.add_result(result)

        break if n == max
        n = @generator.call(n)
      end
    end
  end
end
