module Perfer
  class RGrapher
    attr_reader :r
    def initialize
      require 'rinruby'
      @r = RinRuby.new(false, false)
    end

    def boxplot(results)
      data = results.map { |result|
        result.data.map { |m| m[:real]/result[:iterations] }
      }

      data.each_with_index { |d,i| r.assign("data#{i}", d) }
      r.data_rownames = results.map { |result| Formatter.short_ruby_description(result[:ruby]) }
      r.main_title = "#{results.first[:session]} : #{results.first[:job]}"
      r.eval <<-EOR
      pdf("graph.pdf", paper="a4", height=12)
      data = list(#{data.size.times.map { |i| "data#{i}" } * ',' })
      names(data) = data_rownames
      par(mar=c(20,4,4,2), las=2, cex.axis=.8)
      boxplot(data, main=main_title)
      EOR
    end
  end
end
