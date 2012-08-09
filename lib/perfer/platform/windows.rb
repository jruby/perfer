module Perfer::Platform
  module Windows
    module Types
      BOOL = :bool
      DWORD = :uint32
      HANDLE = :pointer
      SIZE_T = :size_t
      LPSTR = :string
    end

    class PProcessMemoryCounters < FFI::Struct
      include Types
      layout  :cb, DWORD,
              :PageFaultCount, DWORD,
              :PeakWorkingSetSize, SIZE_T,
              :WorkingSetSize, SIZE_T,
              :QuotaPeakPagedPoolUsage, SIZE_T,
              :QuotaPagedPoolUsage, SIZE_T,
              :QuotaPeakNonPagedPoolUsage, SIZE_T,
              :QuotaNonPagedPoolUsage, SIZE_T,
              :PagefileUsage, SIZE_T,
              :PeakPagefileUsage, SIZE_T
    end

    module Kernel32
      include Types
      extend FFI::Library
      ffi_lib 'kernel32'
      ffi_convention :stdcall

      attach_function :GetCurrentProcess, [], HANDLE
      attach_function :GetCommandLineA, [], LPSTR
    end

    module PSAPI
      include Types
      extend FFI::Library
      ffi_lib 'psapi'
      ffi_convention :stdcall

      attach_function :GetProcessMemoryInfo, [HANDLE, PProcessMemoryCounters, DWORD], BOOL
    end

    def get_process_memory_info
      process = Kernel32.GetCurrentProcess
      info = PProcessMemoryCounters.new
      # See http://msdn.microsoft.com/en-us/library/windows/desktop/ms683219%28v=vs.85%29.aspx
      r = PSAPI.GetProcessMemoryInfo(process, info, info.size)
      if !r
        warn "Could not retrieve memory information with GetProcessMemoryInfo()"
        nil
      else
        yield(info)
      end
    ensure
      info.pointer.free if info
    end
    private :get_process_memory_info

    def memory_used
      get_process_memory_info { |info|
        # info[:PeakWorkingSetSize] # RAM
        info[:PeakPagefileUsage] # RAM + SWAP
      }
    end

    def maximum_memory_used
      get_process_memory_info { |info|
        # info[:WorkingSetSize] # RAM
        info[:PagefileUsage] # RAM + SWAP
      }
    end

    def command_line
      Kernel32.GetCommandLineA().tap do |command_line|
        unless command_line
          warn "Could not get command line via GetCommandLineA()"
          return nil
        end
      end
    end
  end
end
