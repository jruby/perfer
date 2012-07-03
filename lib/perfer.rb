require 'epath'

module Perfer
  Path.require_tree

  class << self
    def run(argv)
      files = argv

      files.each do |file|
        require File.expand_path(file)
      end
    end

    def session(title, &block)
      Session.new(title, &block)
    end
  end
end
