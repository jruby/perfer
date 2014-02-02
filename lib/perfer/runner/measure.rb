module Perfer
  class << self
    MINIMAL_RESOLUTION = 1e-6

    # CLOCK_PROCESS_CPUTIME_ID is not affected by other processes (user + system time)
    # resolution is 1e-6 on Darwin (via getrusage(2)), 1e-9 on Linux
    if Process.respond_to?(:clock_gettime) and
       clock_id = Process::CLOCK_PROCESS_CPUTIME_ID and
       Process.clock_getres(clock_id) <= MINIMAL_RESOLUTION
      def cpu_time
        Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID, :nanosecond)
      end
    else
      def cpu_time
        raise "Could not find an appropriate cpu time clock on your system"
      end
    end

    if Process.respond_to?(:clock_gettime) and
       clock_id = Process::CLOCK_MONOTONIC and
       Process.clock_getres(clock_id) <= MINIMAL_RESOLUTION

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
      end

    elsif defined?(JRuby) and java.lang.System.nanoTime()

      JAVA_SYSTEM = java.lang.System
      def monotonic_time
        JAVA_SYSTEM.nanoTime()
      end

    else

      # TODO: try clock_gettime(CLOCK_MONOTONIC) on POSIX
      # TODO: try mach_absolute_time() on OS X
      # TODO: try QueryPerformanceCounter() on Windows

      raise "Could not find an appropriate monotonic clock on your system"

    end

    def measure
      times_before = Process.times
      t0 = monotonic_time
      yield
      t1 = monotonic_time
      times = Process.times

      real = t1 - t0
      real = real / 1e9 if Integer === real

      data = { :real => real }
      times.members.each { |field|
        # precision of times(3) or getrusage(2) is no more than 1e-6
        value = (times[field] - times_before[field]).round(6)
        if value != 0.0 # do not keep these if they measured nothing
          data[field.to_sym] = value
        end
      }
      data
    end
  end
end
