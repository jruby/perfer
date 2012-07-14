# encoding: utf-8

module Perfer
  class Reporter
    extend Forwardable

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
          if r[:iterations]
            time_per_i = format_time a[:mean]/r[:iterations]
            error = "%5.1f" % a[:percent_incertitude]
            puts "#{job_title(r)} #{time_per_i}/i ±#{error}% <=> #{format_ips a[:ips]} ips"
          else
            n = format_n(r[:n], length_of_max_n)
            puts "#{job_title(r)} #{n} in #{format_time a[:mean]} ±#{"%5.1f" % a[:percent_incertitude]}%"
          end
        end
        puts
      }
    end

    def length_of_max_n
      @length_of_max_n ||= @session.results.map { |r| r[:n] }.max.to_s.size
    end

    def job_title(result)
      result[:job].to_s.ljust(@longest_job_title.length)
    end

    def_instance_delegators :'self.class',
      :format_ruby, :format_ips, :format_n, :format_time

    class << self
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

      def format_n(n, maxlen)
        n.to_s.rjust(maxlen)
      end

      def format_time(time)
        if time > 1.0
          "#{("%5.3f" % time)[0...5]} s "
        elsif time > 0.001
          "#{"%5.3f" % (time*1000.0)} ms"
        else
          "#{"%5.3f" % (time*1000000.0)} µs"
        end
      end
    end
  end
end
