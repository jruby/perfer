require 'yaml'
require 'optparse'
require 'forwardable'
require 'ffi'
require 'epath'
require 'backports/1.9'

Path.require_tree('perfer', :except => %w[platform/])

module Perfer
  DIR = Path('~/.perfer')

  class << self
    attr_reader :sessions, :configuration

    def reset
      @configuration = Configuration.new
      @sessions = []
    end

    def session(name, &block)
      Session.new(Path.file(caller), name, &block)
    end

    def measure
      times_before = Process.times
      realtime_before = Time.now
      yield
      times = Process.times
      realtime = Time.now

      data = { :real => realtime-realtime_before }
      times.members.each { |field|
        # precision of times(3) or getrusage(2) is no more than 1e-6
        value = (times[field] - times_before[field]).round(6)
        if value != 0.0 # do not keep these if they measured nothing
          data[field.to_sym] = value
        end
      }
      data
    end
  end

  Perfer.reset
end
