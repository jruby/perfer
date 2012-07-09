module Perfer
  class Store
    def initialize(session)
      @session = session

      @path = Path('~/.perfer')
      @path.mkdir unless @path.exist?

      @bench_file = session.file

      @project_name = @bench_file.backfind('.[.git]').basename
      @file = @path / @project_name
    end

    def load
      @file.lines.map { |line|
        eval(line)
      }.group_by { |result|
        result[:job]
      }.each_pair { |job_name, results|
        job = @session.jobs.find { |job| job.title == job_name }
        raise "Cannot find corresponding job for #{job_name}" unless job
        results.each { |result|
          job.results << result
        }
      }
    end

    def save(job)
      @file.open('a') { |f|
        job.results.each { |result|
          f.puts result.inspect
        }
      }
    end
  end
end
