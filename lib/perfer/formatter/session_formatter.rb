module Perfer
  class SessionFormatter
    include Formatter

    def initialize(session)
      @session = session
    end

    def report(options = {})
      return puts "No results available." unless @session.results
      session_name = @session.results.first[:session]
      puts session_name
      last_bench_file_checksum = @session.results.first[:bench_file_checksum]
      @session.results.chunk { |r|
        r[:run_time]
      }.each { |run_time, results|
        result = results.first
        if last_bench_file_checksum != result[:bench_file_checksum]
          puts "-- The benchmark script changed --"
          puts
          last_bench_file_checksum = result[:bench_file_checksum]
        end
        puts "Ran at #{format_time run_time} with #{result[:ruby]}"
        ResultsFormatter.new(results).report(options)
        puts
      }
    end
  end
end
