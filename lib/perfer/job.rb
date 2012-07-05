module Perfer
  class Job
    MINIMAL_TIME = 1.0 # 0.2

    attr_reader :session, :title, :results, :metadata
    def initialize(session, title, &block)
      @session = session
      @title = title
      @block = block
      @results = Results.new

      # TODO: add file, checksum
      @metadata = { :title => @session.title, :job => @title }.freeze
    end

    def measurements
      10
    end
  end
end
