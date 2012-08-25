module Perfer
  class CLI
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
    rewrite files+   - rewrite the result files in the latest format

<files+> are a set of benchmark files

Common options:
EOS

    def initialize(argv)
      @argv = argv

      @opts = OptionParser.new do |options|
        options.banner = HELP
        common_options(options)
      end
    end

    def execute
      begin
        @opts.order!(@argv)
      rescue OptionParser::ParseError => e
        error e.message
      end

      @command = @argv.shift
      error "A command must be given, one of: #{COMMANDS*', '}" unless @command
      error "Unknown command: #{@command.inspect}" unless COMMANDS.include? @command

      send(@command)
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

    def report
      measurements = (@argv.shift if @argv.first == '--measurements')
      each_session { |session| session.report_results(:measurements => measurements) }
    end

    def run
      # load files
      files.each do |file|
        require file.path
      end
      Perfer.sessions.each(&:run)
    end

    def results
      case subcommand = @argv.shift
      when "path"
        each_session { |session| puts session.store.file }
      when "delete", "rm"
        each_session { |session| session.store.delete }
      when "rewrite"
        each_session { |session| session.store.rewrite }
      else
        unknown_subcommand subcommand
      end
    end

    def config
      case subcommand = @argv.shift
      when "reset"
        Perfer.configuration.write_defaults
      else
        unknown_subcommand subcommand
      end
    end

    def common_options(options)
      options.on('-t TIME', Float, "Minimal time to run (greater usually improve accuracy)") do |t|
        error "Minimal time must be > 0" if t <= 0
        Perfer.configuration.minimal_time = t
      end
      options.on('-m N', Integer, "Numbers of measurements per job") do |n|
        error "There must be at least 2 measurements" if n < 2
        Perfer.configuration.measurements = n
      end
      options.on('-v', "Verbose") do
        Perfer.configuration.verbose = true
      end
      options.on('-h', '--help', "Show this help") do
        puts options.help
        exit
      end
    end

  private
    def files
      @argv.map { |file| Path(file).expand }
    end

    def load_from_files
      files.each do |file|
        Session.new(file)
      end
    end

    def each_session(&block)
      load_from_files
      Perfer.sessions.each(&block)
    end
  end
end
