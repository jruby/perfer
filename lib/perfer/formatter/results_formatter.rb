module Perfer
  class ResultsFormatter
    include Formatter

    # maximal job length is computed from +jobs+ if given,
    # or deduced from given results
    def initialize(results, jobs = nil)
      @results = Array(results)
      @max_job_length = if jobs
        max_length_of(jobs, &:title)
      else
        max_length_of(@results) { |r| r[:job] }
      end
    end

    def job_title(result)
      result[:job].to_s.ljust(@max_job_length)
    end

    def max_n_length
      @max_n_length ||= max_length_of(@results) { |r| r[:n] }
    end

    def report(options = {})
      measurements = options[:measurements]
      @results.each do |result|
        MeasurementsFormatter.new(result.data).report if measurements
        r = result
        stats = r.stats
        error = format_error(stats.margin_of_error/stats.mean)
        if r[:iterations]
          time_per_i = format_duration(stats.mean/r[:iterations])
          ips = r[:iterations]/stats.mean
          puts "#{job_title(r)} #{time_per_i}/i #{error} <=> #{format_ips ips} ips"
        else
          n = format_n(r[:n], max_n_length)
          puts "#{job_title(r)} #{n} in #{format_duration stats.mean} #{error}"
        end
      end
    end
  end
end
