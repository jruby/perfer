module Perfer
  class Job
    attr_reader :session, :title, :metadata
    def initialize(session, title, &block)
      @session = session
      @title = title
      @block = block

      @metadata = @session.metadata.merge(:job => @title).freeze
    end

    def results
      @session.results.select { |result| result.metadata[:job] == @title }
    end

    def minimal_time
      Perfer.configuration.minimal_time
    end

    def measurements
      Perfer.configuration.measurements
    end
  end
end
