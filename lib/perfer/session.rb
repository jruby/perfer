module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :store, :results, :metadata
    attr_writer :current_job
    def initialize(name, file)
      @name = name
      @file = file
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)
      @store = Store.new(self)
      @results = nil # not an Array, so it errors out if we forgot to load
      @results_to_save = []

      @metadata = {
        :file => @file.path,
        :session => @name,
        :ruby => RUBY_DESCRIPTION,
        :run_time => Time.now
      }
      add_git_metadata
      @metadata.freeze

      yield self
    end

    def add_git_metadata
      if Git.repository?
        @metadata[:git_branch] = Git.current_branch
        @metadata[:git_commit] = Git.current_commit
      end
    end

    def load_results
      @results = @store.load
    end

    def add_result(result)
      @results_to_save << result
      Reporter.new(self).report_single_result(result)
    end

    def run
      puts "Session #{@name} with #{@metadata[:ruby]}"
      print "Taking #{Perfer.configuration.measurements} measurements of"
      puts " at least #{Perfer.configuration.minimal_time}s"
      @jobs.each { |job|
        job.run
      }
      @results_to_save.each { |result|
        @store.append(result)
      }
      @results_to_save.clear
    end

    def report
      load_results
      Reporter.new(self).report
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

    def measure(&block)
      raise Error, WRONG_MEASURE_USE unless InputSizeJob === @current_job
      @current_job.last_measurement = Perfer.measure(&block)
    end

  private
    def check_benchmark_type(expected)
      unless !@type or @type == expected
        raise Error, Errors::MIX_BENCH_TYPES
      end
      @type ||= expected
    end

    def check_unique_job_title(title)
      if @jobs.any? { |job| job.title == title }
        raise Error, Errors::SAME_JOB_TITLES
      end
    end
  end
end
