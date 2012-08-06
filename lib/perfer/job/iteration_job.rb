module Perfer
  class IterationJob < Job
    def initialize(session, title, code, data, &block)
      super(session, title, &block)
      if code and !block
        @data = data || {}
        (class << self; self; end).class_eval <<-EOR
        def measure_call_times_code(n#{@data.keys.map { |k| ", #{k}" }.join})
          Perfer.measure do
            __i = 0
            while __i < n
              #{code}
              __i += 1
            end
          end
        end
        EOR
      end
    end

    def measure_call_times(n)
      GC.start
      if !@block
        measure_call_times_code(n, *@data.values)
      elsif @block.arity == 1
        # give n, the block must iterate n times
        Perfer.measure { @block.call(n) }
      else
        Perfer.measure { n.times(&@block) }
      end.tap { |m| p m if verbose }
    end

    def find_number_of_iterations_required(last_iterations = 1, last_time = 0)
      iterations = last_iterations
      if last_time > 0
        iterations = (minimal_time*1.1 * last_iterations / last_time).ceil
      end
      puts "Start search for iterations: start=#{iterations}" if verbose
      loop do
        puts "iterations: #{iterations}" if verbose
        time = measure_call_times(iterations)[:real]
        break if time > minimal_time

        if time <= 0
          iterations *= 2
          next
        end

        # The 1.1 factor ensure some margin, to be strictly above the minimal time faster
        new_iterations = (minimal_time*1.1 * iterations / time).ceil
        # ensure the number of iterations increases
        if new_iterations <= iterations
          puts "new_iterations <= iterations: #{new_iterations} <= #{iterations}" if verbose
          new_iterations = (iterations*1.5).ceil
        end
        iterations = new_iterations
      end
      puts "End search for iterations: iterations=#{iterations}" if verbose
      iterations
    end

    # median absolute deviation / mean
    def mad(measurements)
      stats = Statistics.new(measurements.map { |m| m[:real] })
      mad = stats.median_absolute_deviation
      mad /= stats.mean
      puts "mad: #{mad}" if verbose
      mad
    end

    def run
      super
      measurements = []

      # Run one iteration, so system-level buffers and other OS warm-up can take place
      # This is usually a very inaccurate measurement, so just discard it
      measure_call_times(1)

      iterations = find_number_of_iterations_required

      measurements_taken = 0
      until measurements.size == number_of_measurements and
            mad(measurements) < 0.01 * measurements_taken / number_of_measurements
        time = measure_call_times(iterations)
        measurements_taken += 1
        if time[:real] < 0.9 * minimal_time
          # restart and find a more appropriate number of iterations
          puts "Restarting, #{time[:real]} < #{minimal_time}" if verbose
          measurements.clear
          measurements_taken = 0
          iterations = find_number_of_iterations_required(iterations, time[:real])
        else
          # circular buffer needed!
          measurements.shift if measurements.size == number_of_measurements
          measurements << time
        end
      end

      result = Result.new(@metadata)
      result[:iterations] = iterations
      result.data = measurements
      @session.add_result(result)
    end
  end
end
