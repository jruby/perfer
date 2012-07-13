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
      if !@block
        measure_call_times_code(n, *@data.values)
      elsif @block.arity == 1
        # give n, the block must iterate n times
        Perfer.measure { @block.call(n) }
      else
        Perfer.measure { n.times(&@block) }
      end
    end

    def run
      result = Result.new(@metadata)
      result.metadata[:ruby] = RUBY_DESCRIPTION
      iterations = 1

      # find an appropriate number of iterations
      loop do
        time = measure_call_times(iterations)[:real]
        break if time > minimal_time

        if time <= 0
          iterations *= 2
          next
        end

        # The 1.25 factor ensure some margin, to be strictly above the minimal time faster
        new_iterations = minimal_time*1.25 * iterations / time
        iterations = new_iterations.ceil
      end

      result.metadata[:iterations] = iterations
      measurements.times do
        result << measure_call_times(iterations)
      end
      @session.add_result(result)
    end

    def report
      results.each do |result|
        puts result.metadata.inspect
        aggregate = result.aggregate
        iterations = result.metadata[:iterations]
        aggregate[:ips] = iterations/aggregate[:mean]
        puts aggregate.inspect
        puts
      end
    end
  end
end
