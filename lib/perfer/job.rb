module Perfer
  class Job
    MINIMAL_TIME = 0.01 # temporary

    attr_reader :session, :title, :results, :metadata
    def initialize(session, title, &block)
      @session = session
      @title = title
      @block = block

      @metadata = @session.metadata.merge(:job => @title).freeze
      @results = []
    end

    def measurements
      10
    end
  end
end
