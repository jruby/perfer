module Perfer
  class InputSizeJob < Job
    attr_writer :last_measurement

    def start
      1024
    end

    def generator(n)
      n * 2
    end

    def measure(n)
      GC.start
      @block.call(n)
      @last_measurement
    end

    def run
      super
      n = start
      # find an appropriate maximal n, acts as warm-up
      loop do
        time = measure(n)[:real]
        break if time > minimal_time
        n = generator(n)
      end

      max = n
      n = start
      loop do
        result = Result.new(@metadata)
        result[:n] = n
        measurements.times do
          result << measure(n)
        end
        @session.add_result(result)

        break if n == max
        n = generator(n)
      end
    end
  end
end
