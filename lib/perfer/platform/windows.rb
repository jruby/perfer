module Perfer::Windows
  module Types
    BOOL = :bool
    DWORD = :uint32
    HANDLE = :pointer
    SIZE_T = :size_t
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
  end

  module PSAPI
    include Types
    extend FFI::Library
    ffi_lib 'psapi'
    ffi_convention :stdcall

    attach_function :GetProcessMemoryInfo, [HANDLE, PProcessMemoryCounters, DWORD], BOOL
  end

  def self.maximum_memory_used
    process = Kernel32.GetCurrentProcess
    info = PProcessMemoryCounters.new
    # See http://msdn.microsoft.com/en-us/library/windows/desktop/ms683219%28v=vs.85%29.aspx
    r = PSAPI.GetProcessMemoryInfo(process, info, info.size)
    if !r
      warn "Could not retrieve memory information with GetProcessMemoryInfo()"
      0
    else
      # info[:PeakWorkingSetSize] # RAM
      info[:PeakPagefileUsage] # RAM + SWAP
    end
  ensure
    info.pointer.free if info
  end
end
