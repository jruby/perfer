module Perfer
  class IterationJob < Job
    def measure_call_times(n, &block)
      data = metadata.merge(:iterations => n)
      Perfer.measure(data) { n.times(&block) }
    end

    def run
      iterations = 1

      # find an appropriate number of iterations
      loop do
        time = measure_call_times(iterations, &@block)[:real]
        break if time > MINIMAL_TIME

        if time <= 0
          iterations *= 2
          next
        end

        # The 1.25 factor ensure some margin, to be strictly above the minimal time faster
        new_iterations = MINIMAL_TIME*1.25 * iterations / time
        iterations = new_iterations.ceil
      end

      measurements.times do
        results << measure_call_times(iterations, &@block).merge(:iterations => iterations)
      end

      @session.store.save(self)

      puts results.to_a
      aggregate = results.aggregate
      aggregate[:ips] = iterations/aggregate[:mean]
      puts aggregate
      puts
    end
  end
end
