# encoding: utf-8

module Perfer
  class Reporter
    def initialize(session)
      @session = session
    end

    def report
      puts @session.name
      @session.results.group_by { |r|
        r[:run_time]
      }.each_pair { |run_time, results|
        puts "Ran at #{run_time}"
        results.each do |r|
          a = r.aggregate
          puts "#{r[:job].to_s.ljust(15)} #{"%.1f" % a[:ips]} ips ±#{"%5.1f" % a[:percent_incertitude]}%"
        end
        puts
      }
    end
  end
end
