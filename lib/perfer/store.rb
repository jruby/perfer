module Perfer
  class Store
    def initialize(session)
      @session = session

      @path = Path('~/.perfer/results')
      @path.mkpath unless @path.exist?

      @bench_file = session.file

      # get the relative path to root, and relocate in @path
      names = @bench_file.each_filename.to_a
      @file = @path.join(*names).rm_ext
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
      @file.dir.mkpath unless @file.dir.exist?
      @file.open('a') { |f|
        job.results.each { |result|
          f.puts result.inspect
        }
      }
    end
  end
end
