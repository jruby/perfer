module Perfer
  module CLI
    def self.run(argv)
      command = argv.shift
      case command
      when "report"
        argv.each do |file|
          require File.expand_path(file)
        end

        Perfer.sessions.each { |session|
          session.store.load
          session.jobs.each(&:report)
        }
      when "run"
        argv.each do |file|
          require File.expand_path(file)
        end
        Perfer.sessions.each(&:run)
      else
        raise ArgumentError, "must give a subcommand"
      end
    end
  end
end
