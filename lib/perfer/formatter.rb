# encoding: utf-8

module Perfer
  module Formatter
    extend self

    TIME_UNITS = {
       0 => "s ",
      -3 => "ms",
      -6 => "µs",
      -9 => "ns"
    }

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

    def format_float(f)
      ('%5.3f' % f)[0...5]
    end

    def format_error(error, base, scale)
      "#{format_float(error*10**-scale)} (#{'%4.1f' % (error / base * 100.0)}%)"
    end

    def format_time(time)
      time.strftime("%F %T")
    end

    def duration_scale(time)
      if time == 0 or time > 1.0
        0
      elsif time > 0.001
        -3
      elsif time > 0.000001
        -6
      else
        -9
      end
    end

    # formats a duration with an 8-chars width
    def format_duration(time, scale = duration_scale(time))
      if time == 0
        "    0   "
      else
        "#{format_float(time*10**-scale)} #{TIME_UNITS[scale]}"
      end
    end

    def format_duration_and_error(time, error, after_unit = "")
      scale = duration_scale(time)
      "#{format_duration(time, scale)}#{after_unit} ± #{format_error(error, time, scale)}"
    end
  end
end
