module Perfer
  module CLI
    COMMANDS = %w[
      config
      help
      report
      results
      run
    ]

    HELP = <<-EOS
Usage:
  perfer <command> [options] arguments

Commands:
  run files+    - run with current ruby
  report files+ - show the results
  config reset  - reset the configuration file to the defaults (or create it)
  help          - show this help
  results
    path files+      - show the paths to the result files
    rm,delete files+ - remove the result files

<files+> are a set of benchmark files

Common options:
EOS

    class << self
      def execute(argv)
        @opts = OptionParser.new do |options|
          options.banner = HELP
          common_options(options)
        end

        begin
          @opts.parse!(argv)
        rescue OptionParser::ParseError => e
          error e.message
        end

        @command = argv.shift
        error "A command must be given, one of: #{COMMANDS*', '}" unless @command
        error "Unknown command: #{@command.inspect}" unless COMMANDS.include? @command

        send(@command, *argv)
      end

      def unknown_subcommand(subcommand)
        if subcommand
          error "Unknown subcommand for #{@command}: #{subcommand.inspect}"
        else
          error "`perfer #{@command}` needs a subcommand"
        end
      end

      def error message
        $stderr.puts message
        $stderr.puts
        abort @opts.help
      end

      def help
        puts @opts.help
      end

      def report(*files)
        load_files(files)
        sessions.each { |session|
          session.report
        }
      end

      def run(*files)
        load_files(files)
        sessions.each(&:run)
      end

      def results(*files)
        case subcommand = files.shift
        when "path"
          load_files(files)
          sessions.each { |session|
            puts session.store.file
          }
        when "delete", "rm"
          load_files(files)
          sessions.each { |session|
            session.store.delete
          }
        when "rewrite"
          load_files(files)
          sessions.each { |session|
            session.store.rewrite
          }
        else
          unknown_subcommand subcommand
        end
      end

      def config(*files)
        case subcommand = files.shift
        when "reset"
          Perfer.configuration.write_defaults
        else
          unknown_subcommand subcommand
        end
      end

      def common_options(options)
        options.on('-t TIME', Float, "Minimal time for to run (greater usually improve accuracy)") do |t|
          error "Minimal time must be > 0" if t <= 0
          Perfer.configuration.minimal_time = t
        end
        options.on('-m N', Integer, "Numbers of measurements per job") do |n|
          error "There must be at least 2 measurements" if n < 2
          Perfer.configuration.measurements = n
        end
        options.on('-h', '--help', "Show this help") do
          puts options.help
          exit
        end
      end

      def load_files(files)
        files.each do |file|
          require File.expand_path(file)
        end
      end

      def sessions
        Perfer.sessions
      end
    end
  end
end
