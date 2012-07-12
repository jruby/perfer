require 'yaml'

module Perfer
  class Store
    attr_reader :file
    def initialize(session)
      @session = session

      @path = Path('~/.perfer/results')
      @path.mkpath unless @path.exist?

      @bench_file = session.file

      # get the relative path to root, and relocate in @path
      names = @bench_file.each_filename.to_a
      @file = @path.join(*names).add_ext('.yml')
    end

    def delete
      @file.unlink
    end

    def load
      return unless @file.exist?
      results = YAML.load_file(@file)
      results.each { |result|
        job = @session.jobs.find { |job| job.title == result.metadata[:job] }
        raise "Cannot find corresponding job for #{job_name}" unless job
        job.results << result
      }
    end

    def save
      @file.dir.mkpath unless @file.dir.exist?
      @file.write YAML.dump(@session.results)
    end
  end
end
