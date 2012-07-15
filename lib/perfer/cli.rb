module Perfer
  module CLI
    COMMANDS = %w[
      config
      report
      results
      run
    ]

    class << self
      def execute(argv)
        command = argv.shift
        unless command
          raise Error, "A command must be given, one of: #{COMMANDS*', '}"
        end
        unless COMMANDS.include?(command)
          raise Error, "Unknown command: #{command.inspect}"
        end

        OptionParser.new do |options|
          common_options(options)
        end.parse!(argv)

        send(command, argv)
      end

      def report(argv)
        load_files(argv)
        sessions.each { |session|
          session.report
        }
      end

      def run(argv)
        load_files(argv)
        sessions.each(&:run)
      end

      def results(argv)
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
        when "rewrite"
          load_files(argv)
          sessions.each { |session|
            session.store.rewrite
          }
        else
          raise Error, "Unknown subcommand: #{subcommand}"
        end
      end

      def config(argv)
        case subcommand = argv.shift
        when "reset"
          Perfer.configuration.write_defaults
        else
          raise Error, "Unknown subcommand: #{subcommand}"
        end
      end

      def common_options(options)
        options.on('-t TIME', Float, "Minimal time for to run (greater usually improve accuracy)") do |t|
          raise Error, "Minimal time must be > 0" if t <= 0
          Perfer.configuration.minimal_time = t
        end
        options.on('-m N', Integer, "Numbers of measurements per job") do |n|
          raise Error, "There must be at least 2 measurements" if n < 2
          Perfer.configuration.measurements = n
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
