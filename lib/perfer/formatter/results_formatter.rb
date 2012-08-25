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

    def max_input_size_length
      @max_input_size_length ||= max_length_of(@results) { |r| r[:input_size] }
    end

    def report(options = {})
      measurements = options[:measurements]
      @results.each do |result|
        MeasurementsFormatter.new(result.data).report if measurements
        r = result
        stats = r.stats
        mean = stats.mean
        error = stats.maximum_absolute_deviation
        if r[:iterations]
          time_per_i, ips = mean/r[:iterations], r[:iterations]/mean
          error /= r[:iterations]
          puts "#{job_title(r)} #{format_duration_and_error time_per_i, error, '/i'} <=> #{format_ips ips} ips"
        else
          n = format_n(r[:input_size], max_input_size_length)
          puts "#{job_title(r)} #{n} in #{format_duration_and_error mean, error}"
        end
      end
    end
  end
end
