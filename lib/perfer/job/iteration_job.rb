module Perfer
  class IterationJob < Job
    # This factor ensure some margin,
    # to avoid endlessly changing the number of iterations
    CHANGE_ITERATIONS_MARGIN = 0.1
    MAX_GROW_FACTOR = 10
    UNIQUE_NAME = "a"

    def repeat_eval
      100
    end

    def initialize(session, title, code = nil, data = nil, &block)
      super(session, title, &block)
      load_metadata
      compile_method(code, data) if code and !block
    end

    def compile_method(code, data)
      @data = data || {}
      if obj = @data.delete(:self)
        klass = obj.singleton_class
        meth = generate_method_name
      else
        klass = singleton_class
        meth = :measure_call_times_code
      end

      if klass.method_defined?(meth)
        raise Error, "method #{meth} already defined on #{klass} (#{obj})!"
      end

      begin
        klass.class_eval <<-EOR
        def #{meth}(__n#{@data.keys.map { |k| ", #{k}" }.join})
          ::Perfer.measure do
            __i = 0
            while __i < __n
              #{"#{code}; " * repeat_eval}
              __i += 1
            end
          end
        end
        EOR
      rescue SyntaxError => e
        raise Error, "There was an error while eval'ing the code: #{code.inspect}\n#{e}"
      end

      if obj
        singleton_class.send(:define_method, :measure_call_times_code) do |*args|
          obj.send(meth, *args)
        end
      end
    end

    def generate_method_name
      :"perfer_eval_#{UNIQUE_NAME.succ!}"
    end

    def measure_call_times(n)
      GC.start
      if !@block
        if n % repeat_eval != 0
          raise Error, "Implementation error: #{n} not multiple of #{repeat_eval}"
        end
        n /= repeat_eval
        measure_call_times_code(n, *@data.values)
      elsif @block.arity == 1
        # give n, the block must iterate n times
        Perfer.measure { @block.call(n) }
      else
        Perfer.measure { n.times(&@block) }
      end.tap { |m| p m if verbose }
    end

    def round_for_eval(iterations)
      if @block
        iterations
      else
        ((iterations + repeat_eval - 1) / repeat_eval) * repeat_eval
      end
    end

    def compute_new_iterations(iterations, time)
      (minimal_time * iterations / time).ceil
    end

    def find_number_of_iterations_required(last_iterations = 1, last_time = 0)
      iterations = last_iterations
      if last_time > 0
        iterations = compute_new_iterations(last_iterations, last_time)
      end
      iterations = round_for_eval(iterations)
      puts "Start search for iterations: start=#{iterations}" if verbose
      loop do
        puts "iterations: #{iterations}" if verbose
        time = measure_call_times(iterations)[:real]
        break if time > minimal_time

        if time <= 0
          iterations *= 2
          next
        end

        new_iterations = compute_new_iterations(iterations, time)
        # ensure the number of iterations increases
        if new_iterations <= iterations
          puts "new_iterations <= iterations: #{new_iterations} <= #{iterations}" if verbose
          new_iterations = (iterations*1.5).ceil
        end
        if new_iterations > MAX_GROW_FACTOR * iterations
          new_iterations = MAX_GROW_FACTOR * iterations
        end
        iterations = round_for_eval(new_iterations)
      end
      puts "End search for iterations: iterations=#{iterations}" if verbose
      iterations
    end

    # median absolute deviation / median
    def mad(measurements)
      stats = Statistics.new(measurements.map { |m| m[:real] })
      mad = stats.median_absolute_deviation
      mad /= stats.median
      puts "mad: #{mad}" if verbose
      mad
    end

    def run
      super
      measurements = []

      # Run one iteration, so system-level buffers and other OS warm-up can take place
      # This is usually a very inaccurate measurement, so just discard it
      measure_call_times(round_for_eval(1))

      iterations = find_number_of_iterations_required

      measurements_taken = 0
      until measurements.size == number_of_measurements and
            mad(measurements) < 0.01 * measurements_taken / number_of_measurements
        time = measure_call_times(iterations)
        measurements_taken += 1
        if time[:real] < (1.0 - CHANGE_ITERATIONS_MARGIN) * minimal_time
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
