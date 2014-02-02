module Perfer
  class Session
    attr_reader :name, :file, :jobs, :type, :metadata, :store, :results
    def initialize(file, name = nil, &block)
      @file = file
      @name = name || file.base.to_s
      @store = Store.for_session(self)
      @results = nil # not an Array, so it errors out if we forgot to load

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
        # :command_line => TODO,
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
  end
end
