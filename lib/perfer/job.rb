module Perfer
  class Job
    MINIMAL_TIME = 1.0 # 0.2

    attr_reader :session, :title, :results, :metadata
    def initialize(session, title, &block)
      @session = session
      @title = title
      @block = block
      @results = [].extend(Results)

      # TODO: add file, checksum
      @metadata = {
        :ruby => RUBY_DESCRIPTION,
        :file => session.file.path,
        :session => @session.name,
        :job => @title
      }.freeze
    end

    def measurements
      10
    end
  end
end
