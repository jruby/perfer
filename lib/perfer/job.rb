module Perfer
  class Job
    MINIMAL_TIME = 0.01 # temporary

    attr_reader :session, :title, :results, :metadata
    def initialize(session, title, &block)
      @session = session
      @title = title
      @block = block

      # TODO: add file, checksum
      @metadata = {
        :file => session.file.path,
        :session => @session.name,
        :job => @title
      }.freeze

      @results = []
    end

    def measurements
      10
    end
  end
end
