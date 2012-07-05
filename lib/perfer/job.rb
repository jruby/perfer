module Perfer
  class Job
    MINIMAL_TIME = 1.0 # 0.2

    attr_reader :session, :title, :results
    def initialize(session, title, &block)
      @session = session
      @title = title
      @block = block
      @results = Results.new
    end

    def measurements
      10
    end

    def metadata
      # TODO: add file, checksum
      @metadata ||= { :title => @session.title, :job => title }.freeze
    end
  end
end
