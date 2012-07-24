# encoding: utf-8

module Perfer
  module Formatter
    extend self

    def max_length_of(enum)
      max = 0
      enum.each { |e|
        alt = yield(e).to_s.length
        max = alt if alt > max
      }
      max
    end

    def format_ips(ips)
      if ips > 100
        ips.round
      else
        ips.round(1)
      end
    end

    def format_n(n, maxlen)
      n.to_s.rjust(maxlen)
    end

    def format_error(error)
      "±%5.1f%%" % (error * 100.0)
    end

    def format_time(time)
      time.strftime("%F %T")
    end

    def format_duration(time)
      if time > 1.0
        "#{("%5.3f" % time)[0...5]} s "
      elsif time > 0.001
        "#{("%5.3f" % (time*1000.0))[0...5]} ms"
      else
        "#{("%5.3f" % (time*1000000.0))[0...5]} µs"
      end
    end
  end
end
