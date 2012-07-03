module Perfer
  class Job
    attr_reader :title

    def initialize(title, &block)
      @title = title
      @block = block
    end

    def run

    end
  end
end
