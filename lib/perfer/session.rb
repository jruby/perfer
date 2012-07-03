module Perfer
  class Session
    attr_reader :title, :jobs, :type

    def initialize(title)
      @title = title
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)

      yield self

      @jobs.each { |job|
        job.run
      }
    end

    def iterate(title, &block)
      check_benchmark_type(:iterations)
      @jobs << IterationJob.new(title, &block)
    end

    def bench(title, &block)
      check_benchmark_type(:input_size)
      @jobs << InputSizeJob.new(title, &block)
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
