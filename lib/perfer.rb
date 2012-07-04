require 'epath'

module Perfer
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

    def measure
      times_before = Process.times
      realtime_before = Time.now
      yield
      times = Process.times
      realtime = Time.now

      realtime -= realtime_before
      times.members.each { |field| times[field] -= times_before[field] }
      [realtime, times]
    end
  end
end

Path.require_tree('perfer', :except => %w[platform/])
