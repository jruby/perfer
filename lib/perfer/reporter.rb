# encoding: utf-8

module Perfer
  class Reporter
    def initialize(session)
      @session = session

      @longest_job_title = @session.jobs.map(&:title).max_by(&:size)
    end

    def report
      puts @session.name
      @session.results.group_by { |r|
        r[:run_time]
      }.each_pair { |run_time, results|
        puts "Ran at #{run_time} with #{format_ruby results.first[:ruby]}"
        results.each do |r|
          a = r.aggregate
          puts "#{job_title(r)} #{format_ips a[:ips]} ips ±#{"%5.1f" % a[:percent_incertitude]}%"
        end
        puts
      }
    end

    def format_ruby(description)
      description[/\A.+?\)/]
    end

    def format_ips(ips)
      if ips > 100
        ips.round
      else
        ips.round(1)
      end
    end

    def job_title(result)
      result[:job].to_s.ljust(@longest_job_title.size)
    end
  end
end
