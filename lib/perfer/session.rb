module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :store, :metadata
    def initialize(name, file)
      @name = name
      @file = file
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)
      @store = Store.new(self)

      @metadata = {
        :file => @file.path,
        :session => @name
      }.freeze

      yield self

      @store.load
    end

    def results
      @jobs.reduce([]) { |results, job|
        results.concat job.results
      }
    end

    def run
      @jobs.each { |job|
        job.run
      }
      @store.save
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
