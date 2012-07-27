module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :store, :results, :metadata
    attr_writer :current_job
    def initialize(file, name = nil, &block)
      @file = file
      @name = name
      @store = Store.new(self)
      @results = nil # not an Array, so it errors out if we forgot to load

      setup_for_run(&block) if block_given?

      Perfer.sessions << self
    end

    def setup_for_run
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)
      @results_to_save = []

      @metadata = {
        :file => @file.path,
        :session => @name,
        :ruby => RUBY_DESCRIPTION,
        :command_line => Platform.command_line,
        :run_time => Time.now
      }
      add_git_metadata
      add_bench_file_checksum
      @metadata.freeze

      yield self
    end

    def add_git_metadata
      if Git.repository?
        @metadata[:git_branch] = Git.current_branch
        @metadata[:git_commit] = Git.current_commit
      end
    end

    def add_bench_file_checksum
      checksum = Digest::SHA1.hexdigest(@file.binread)
      if checksum.respond_to?(:encoding) and checksum.encoding != Encoding::ASCII
        checksum.force_encoding(Encoding::ASCII)
      end
      @metadata[:bench_file_checksum] = checksum
    end

    def load_results
      @results = @store.load
    end

    def add_result(result)
      @results_to_save << result
      ResultsFormatter.new(result, @jobs).report
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

    # not named #report, to avoid any confusion with Benchmark's #report
    def report_results(options = {})
      load_results
      SessionFormatter.new(self).report(options)
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
