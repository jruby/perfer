module Perfer
  class << self
    def run(argv)
      files = argv

      files.each do |file|
        require File.expand_path(file)
      end
    end
  end
end
