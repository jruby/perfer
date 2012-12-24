module Perfer
  class Job
    extend Forwardable
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

    def_delegators 'Perfer.configuration', :minimal_time, :verbose
    def_delegator 'Perfer.configuration', :measurements, :number_of_measurements

    def run
      @session.current_job = self
    end
  end
end
