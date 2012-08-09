module Perfer::Platform
  module POSIX
    class TimeValStruct < FFI::Struct
      layout  :tv_sec, :time_t,
              :tv_usec, :suseconds_t
    end

    class RUsageStruct < FFI::Struct
      # Rubinius FFI can't handle nested structs
      layout  :ru_utime_tv_sec, :time_t, # :ru_utime, TimeValStruct,
              :ru_utime_tv_usec, :suseconds_t,
              :ru_stime_tv_sec, :time_t, # :ru_stime, TimeValStruct,
              :ru_stime_tv_usec, :suseconds_t,
              :ru_maxrss, :long,
              :ru_ixrss, :long,
              :ru_idrss, :long,
              :ru_isrss, :long,
              :ru_minflt, :long,
              :ru_majflt, :long,
              :ru_nswap, :long,
              :ru_inblock, :long,
              :ru_oublock, :long,
              :ru_msgsnd, :long,
              :ru_msgrcv, :long,
              :ru_nsignals, :long,
              :ru_nvcsw, :long,
              :ru_nivcsw, :long
    end

    module LibC
      extend FFI::Library
      ffi_lib FFI::Library::LIBC

      RUSAGE_SELF = 0

      attach_function :getrusage, [:int, :pointer], :int
    end

    PID = Process.pid

    def memory_used
      case OS
      when /^darwin/, /^linux/, /^solaris/
        Integer(`ps -o rss= -p #{PID}`) * 1024
      else
        warn "Unknown platform for Platform.command_line: #{os.inspect}"
        nil
      end
    end

    def maximum_memory_used
      rusage = RUsageStruct.new
      r = LibC.getrusage(LibC::RUSAGE_SELF, rusage)
      if r != 0
        warn "Could not retrieve memory information with getrusage(2)"
        0
      else
        m = rusage[:ru_maxrss]
        warn "Memory information with getrusage(2) is inaccurate, ru_maxrss was 0" if m == 0
        if /darwin/ =~ OS
          m # reported in bytes
        else
          m * 1024 # reported in KB, as the man page says
        end
      end
    ensure
      rusage.pointer.free if rusage
    end

    def command_line
      case OS
      when /^darwin/, /^linux/, /^solaris/
        `ps -o args= -p #{PID}`.lines.to_a.last.rstrip
      else
        warn "Unknown platform for Platform.command_line: #{os.inspect}"
        nil
      end
    end
  end
end
