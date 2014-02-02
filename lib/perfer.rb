if defined? Perfer
  raise LoadError, "Perfer is already loaded in " \
  "#{$LOADED_FEATURES.find { |f| f.end_with? 'lib/perfer.rb' }}. " \
  "Current file is #{__FILE__}."
end

if RUBY_VERSION < '1.9'
  raise LoadError, "Perfer driver needs to be run by a ruby >= 1.9"
end

require 'yaml'
require 'path'
require 'optparse'
require 'hitimes'
require 'digest/sha1'

Path.require_tree('perfer')

module Perfer
  DIR = Path('~/.perfer')
  TIMES_FIELDS = [:real, :utime, :stime, :cutime, :cstime].freeze

  class << self
    attr_reader :sessions, :configuration

    def reset
      @configuration = Configuration.new
      @sessions = []
    end

    def session(name = nil, &block)
      Session.new(Path.file(caller), name, &block)
    end

    # Shortcut for Perfer.session { |s| s.iterate ... }
    def iterate(title = nil, *args, &block)
      Session.new(Path.file(caller)) { |session|
        title ||= session.object.name
        session.iterate(title, *args, &block)
      }
    end
  end

  Perfer.reset
end
