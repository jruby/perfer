module Perfer
  module CLI
    class << self
      def run(argv)
        case command = argv.shift
        when "report"
          load_files(argv)
          sessions.each { |session|
            session.report
          }
        when "run"
          load_files(argv)
          sessions.each(&:run)
        when "results"
          case subcommand = argv.shift
          when "path"
            load_files(argv)
            sessions.each { |session|
              puts session.store.file
            }
          when "delete", "rm"
            load_files(argv)
            sessions.each { |session|
              session.store.delete
            }
          else
            raise "Unknown subcommand"
          end
        when "config"
          case subcommand = argv.shift
          when "reset"
            Perfer.configuration.write_defaults
          end
        else
          raise ArgumentError, "must give a subcommand"
        end
      end

      def load_files(argv)
        argv.each do |file|
          require File.expand_path(file)
        end
      end

      def sessions
        Perfer.sessions
      end
    end
  end
end
