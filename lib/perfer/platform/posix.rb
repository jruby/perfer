module Perfer::POSIX
  class TimeValStruct < FFI::Struct
    layout  :tv_sec, :time_t,
            :tv_usec, :suseconds_t
  end

  class RUsageStruct < FFI::Struct
    layout  :ru_utime, TimeValStruct,
            :ru_stime, TimeValStruct,
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

  def self.memory_used
    pid = Process.pid
    case os = RbConfig::CONFIG['host_os']
    when /^darwin/, /^linux/, /^solaris/
      Integer(`ps -o rss= -p #{pid}`) * 1024
    else
      warn "Unknown platform for Platform.command_line: #{os.inspect}"
      nil
    end
  end

  def self.maximum_memory_used
    rusage = RUsageStruct.new
    r = LibC.getrusage(LibC::RUSAGE_SELF, rusage)
    if r != 0
      warn "Could not retrieve memory information with getrusage(2)"
      0
    else
      m = rusage[:ru_maxrss]
      warn "Memory information with getrusage(2) is inaccurate, ru_maxrss was 0" if m == 0
      if FFI::Platform::OS == 'darwin'
        m # reported in bytes
      else
        m * 1024 # reported in KB, as the man page says
      end
    end
  ensure
    rusage.pointer.free if rusage
  end

  def self.command_line
    pid = Process.pid
    case os = RbConfig::CONFIG['host_os']
    when /^darwin/, /^linux/, /^solaris/
      `ps -o args= -p #{pid}`.lines.to_a.last.rstrip
    else
      warn "Unknown platform for Platform.command_line: #{os.inspect}"
      nil
    end
  end
end
