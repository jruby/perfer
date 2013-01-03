module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :metadata, :store, :results
    attr_accessor :current_job, :next_job_metadata
    def initialize(file, name = nil, &block)
      @file = file
      @name = name || file.base.to_s
      @store = Store.for_session(self)
      @results = nil # not an Array, so it errors out if we forgot to load

      run(&block) if block_given?

      Perfer.sessions << self
    end

    def setup_for_run
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)
      @results_to_save = []
      @next_job_metadata = nil

      @metadata = {
        :file => @file.path,
        :session => @name,
        :ruby => RUBY_DESCRIPTION,
        :command_line => Platform.command_line,
        :run_time => Time.now
      }
      add_config_metadata
      add_git_metadata
      add_bench_file_checksum
      @metadata.freeze
    end

    def add_config_metadata
      config = Perfer.configuration.to_hash
      config.delete(:verbose) # Not relevant to save
      @metadata.merge!(config)
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
      ResultsFormatter.new(result).report
    end

    def run(&block)
      setup_for_run
      puts "Session #{@name} with #{@metadata[:ruby]}"
      print "Taking #{Perfer.configuration.measurements} measurements of"
      puts " at least #{Perfer.configuration.minimal_time}s"

      block.call DSL.new(self)

      @results_to_save.each { |result|
        @store.append(result)
      }
      if Perfer.configuration.verbose
        puts
        ResultsFormatter.new(@results_to_save).report
      end
      @results_to_save.clear
    end

    def report(options = {})
      load_results
      SessionFormatter.new(self).report(options)
    end

    def graph
      load_results
      # consider only first job for now
      last_runtime = @results.last[:runtime]
      job = @results.reverse_each.take_while { |r| r[:runtime] == last_runtime }.last[:job]
      data = @results.select { |r| r[:job] == job }.
                      sort_by { |r| r[:ruby] }.
                      chunk { |r| r[:ruby] }.
                      map { |ruby, results| results.last }
      RGrapher.new.boxplot(data)
    end

    def add_job(job_type, title, *args, &block)
      check_benchmark_type(job_type)
      check_unique_job_title(title)
      @jobs << job = job_type.new(self, title, *args, &block)
      job.run
      @next_job_metadata = nil
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

    class DSL
      def initialize(session)
        @session = session
      end

      def object
        @session
      end

      def metadata(&block)
        if !block
          @session.metadata
        else
          @session.next_job_metadata = MetadataSetter.new.tap do |metadata|
            metadata.instance_eval(&block)
          end.to_hash
        end
      end

      def iterate(title, code = nil, data = nil, &block)
        @session.add_job(IterationJob, title, code, data, &block)
      end

      def bench(title, &block)
        @session.add_job(InputSizeJob, title, &block)
      end

      def measure(&block)
        raise Error, WRONG_MEASURE_USE unless InputSizeJob === @session.current_job
        @session.current_job.last_measurement = Perfer.measure(&block)
      end
    end

    class MetadataSetter
      def initialize
        @metadata = {}
      end

      def description description
        @metadata[:description] = description
      end

      def tags *tags
        @metadata[:tags] ||= []
        @metadata[:tags] |= tags.map(&:to_s)
      end

      def start n
        @metadata[:start] = n
      end

      def generator &block
        @metadata[:generator] = block
      end

      def to_hash
        @metadata
      end
    end
  end
end
