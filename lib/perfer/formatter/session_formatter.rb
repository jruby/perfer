module Perfer
  class SessionFormatter
    include Formatter

    def initialize(session)
      @session = session
    end

    def report
      return puts "No results available." unless @session.results
      session_name = @session.results.first[:session]
      puts session_name
      @session.results.chunk { |r|
        r[:run_time]
      }.each { |run_time, results|
        puts "Ran at #{format_time run_time} with #{results.first[:ruby]}"
        ResultFormatter.new(results).report
        puts
      }
    end
  end
end
