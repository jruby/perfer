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
        "%.3g" % ips
      end.to_s.rjust(9)
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

    def float_scale(time)
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
    def format_duration(time, scale = float_scale(time))
      if time == 0
        "    0   "
      else
        "#{format_float(time*10**-scale)} #{TIME_UNITS[scale]}"
      end
    end

    def format_duration_and_error(time, error, after_unit = "")
      scale = float_scale(time)
      "#{format_duration(time, scale)}#{after_unit} ± #{format_error(error, time, scale)}"
    end

    def ruby_version(desc)
      # # ruby 2.0.0dev (2012-08-25 trunk 36824) [x86_64-darwin10.8.0]
      case desc
      when /^ruby (\d\.\d\.\d) .+ patchlevel (\d+)/
        "#{$1}p#{$2}"
      when /^ruby (\d\.\d\.\d(?:p\d+|\w+)) .+ (?:trunk|revision) (\d+)/
        "#{$1} r#{$2}"
      when /^rubinius .+? \((\d\.\d\.\d) /
        $1
      when /^jruby .+? \(ruby-(\d\.\d\.\d)-p(\d+)\)/,
           /^jruby .+? \((\d\.\d\.\d)p(\d+)\)/
        "#{$1}p#{$2}"
      when /^MacRuby .+? \(ruby (\d\.\d\.\d)\)/
        $1
      else
        raise "Unknown ruby version: #{desc}"
      end
    end

    def short_ruby_description(desc)
      impl, version = nil, nil
      case desc
      when /Ruby Enterprise Edition (\d{4}\.\d{2})$/
        impl, version = "ree", $1
      when /^MacRuby (\S+)/
        impl, version = "macruby", $1
      when /^rubinius (\S+) \(\d\.\d\.\d release (\d{4}-\d{2}-\d{2})/,
           /^rubinius (\S+) \(\d\.\d\.\d ([0-9a-f]+) /
        impl, version = "rbx", "#{$1} #{$2}"
      when /^jruby (\S+) \(.+?\) \(\d{4}-\d{2}-\d{2} ([0-9a-f]+)\)/,
           /^jruby (\S+) \(.+?\) (\d{4}-\d{2}-\d{2}) f+/,
           /^jruby (\S+) \(.+?\) \d{4}-\d{2}-\d{2} ([0-9a-f]+)/
        impl, version = "jruby", "#{$1} #{$2}"
      when /^ruby /
        impl = "mri"
      else
        raise "Unknown ruby interpreter: #{desc}"
      end
      ruby_version = ruby_version(desc)

      if version
        "#{impl} #{version} (#{ruby_version})"
      else
        "#{impl} #{ruby_version}"
      end
    end
  end
end
