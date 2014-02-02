module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :metadata, :results
    attr_accessor :current_job, :next_job_metadata
    def initialize(file, name = nil, &block)
      if Perfer.sessions.any? { |session| session.file == file }
        raise "Only one Session per file: #{file}"
      end
      @file = file
      @name = name || file.base.to_s

      run(&block)
    end

    def setup_for_run
      @jobs = []
      @type = nil # will be decided by API usage (iterate/bench)
      @results_to_save = []
      @next_job_metadata = nil

      @metadata = {
        :session => @name,
        :ruby => RUBY_DESCRIPTION,
      }.freeze
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
