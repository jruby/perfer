module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :store
    def initialize(name, file)
      @name = name
      @file = file
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)
      @store = Store.new(self)

      yield self
    end

    def run
      @jobs.each { |job|
        job.run
      }
    end

    def iterate(title, &block)
      check_benchmark_type(:iterations)
      @jobs << IterationJob.new(self, title, &block)
    end

    def bench(title, &block)
      check_benchmark_type(:input_size)
      @jobs << InputSizeJob.new(self, title, &block)
    end

  private
    def check_benchmark_type(expected)
      unless !@type or @type == expected
        raise "Cannot mix iterations and input size benchmarks in the same session"
      end
      @type ||= expected
    end
  end
end
