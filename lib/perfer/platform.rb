module Perfer
  module Platform
    OS = RbConfig::CONFIG['host_os']

    if /mingw|mswin/ =~ OS
      require Path.relative('platform/windows')
      extend Windows
    else
      require Path.relative('platform/posix')
      extend POSIX
    end
  end
end
