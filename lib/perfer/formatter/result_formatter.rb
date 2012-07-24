module Perfer
  class ResultFormatter
    include Formatter

    # session is used to calculate the maximal job title length
    def initialize(session)
      @session = session
      @max_job_length = max_length_of(session.jobs, &:title)
    end

    def job_title(result)
      result[:job].to_s.ljust(@max_job_length)
    end

    def max_n_length
      @max_n_length ||= @session.results ? max_length_of(@session.results) { |r| r[:n] } : 7
    end

    def report(result)
      r = result
      a = r.aggregate
      error = format_error a[:margin_of_error]
      if r[:iterations]
        time_per_i = format_duration(a[:mean]/r[:iterations])
        puts "#{job_title(r)} #{time_per_i}/i #{error} <=> #{format_ips a[:ips]} ips"
      else
        n = format_n(r[:n], max_n_length)
        puts "#{job_title(r)} #{n} in #{format_duration a[:mean]} #{error}"
      end
    end
  end
end
