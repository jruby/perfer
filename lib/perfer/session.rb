module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :store, :results, :metadata
    def initialize(name, file)
      @name = name
      @file = file
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)
      @store = Store.new(self)
      @results = nil # not an Array, so it errors out if we forgot to load

      @metadata = {
        :file => @file.path,
        :session => @name,
        :run_time => Time.now
      }.freeze

      yield self
    end

    def load_results
      @results = @store.load
    end

    def add_result(result)
      @store.append(result)
    end

    def run
      @jobs.each { |job|
        job.run
      }
    end

    def report
      load_results
      @jobs.each(&:report)
    end

    def iterate(title, code = nil, data = nil, &block)
      check_benchmark_type(:iterations)
      check_unique_job_title(title)
      @jobs << IterationJob.new(self, title, code, data, &block)
    end

    def bench(title, &block)
      check_benchmark_type(:input_size)
      check_unique_job_title(title)
      @jobs << InputSizeJob.new(self, title, &block)
    end

  private
    def check_benchmark_type(expected)
      unless !@type or @type == expected
        raise "Cannot mix iterations and input size benchmarks in the same session"
      end
      @type ||= expected
    end

    def check_unique_job_title(title)
      if @jobs.any? { |job| job.title == title }
        raise "Multiple jobs with the same title are not allowed"
      end
    end
  end
end
