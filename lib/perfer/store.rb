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
