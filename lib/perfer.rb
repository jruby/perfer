require 'epath'

module Perfer
  @sessions = []

  class << self
    def run(argv)
      if argv.first == "report"
        argv.shift

        argv.each do |file|
          require File.expand_path(file)
        end
        @sessions.each { |session|
          session.store.load
          session.jobs.each(&:report)
        }
      else
        files = argv

        files.each do |file|
          require File.expand_path(file)
        end
        @sessions.each(&:run)
      end
    end

    def session(title, &block)
      session = Session.new(title, Path.file(caller), &block)
      @sessions << session
      session
    end

    def measure(result = {})
      times_before = Process.times
      realtime_before = Time.now
      yield
      times = Process.times
      realtime = Time.now

      result[:real] = realtime-realtime_before
      times.members.each { |field|
        # precision of times(3) or getrusage(2) is no more than 1e-6
        result[field.to_sym] = (times[field] - times_before[field]).round(6)
      }
      result
    end
  end
end

Path.require_tree('perfer', :except => %w[platform/])
