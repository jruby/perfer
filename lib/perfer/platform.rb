module Perfer
  Platform = if FFI::Platform.windows?
    require Path.relative('platform/windows')
    Windows
  else
    require Path.relative('platform/posix')
    POSIX
  end
end
