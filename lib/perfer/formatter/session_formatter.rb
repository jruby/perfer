module Perfer
  class SessionFormatter
    include Formatter

    def initialize(session)
      @session = session
      @result_formatter = ResultFormatter.new(session)
    end

    def report
      puts @session.name
      return puts "No results available." unless @session.results
      @session.results.group_by { |r|
        r[:run_time]
      }.each_pair { |run_time, results|
        puts "Ran at #{format_time run_time} with #{results.first[:ruby]}"
        results.each do |result|
          @result_formatter.report(result)
        end
        puts
      }
    end
  end
end
