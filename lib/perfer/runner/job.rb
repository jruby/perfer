module Perfer
  class Job
    attr_reader :session, :title, :metadata
    def initialize(session, title, &block)
      @session = session
      @title = title
      @block = block
    end

    def load_metadata
      @metadata = @session.metadata.merge(:job => @title)
      @metadata.merge!(@session.next_job_metadata) if @session.next_job_metadata
      @metadata.freeze
    end

    def results
      @session.results.select { |result| result[:job] == @title }
    end

    def minimal_time
      Perfer.configuration.minimal_time
    end

    def verbose
      Perfer.configuration.verbose
    end

    def number_of_measurements
      Perfer.configuration.measurements
    end

    def run
      @session.current_job = self
    end
  end
end
