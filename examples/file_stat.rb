require 'tmpdir'
tmpdir = Dir.tmpdir

Perfer.session "File.stat" do |b|
  b.iterate "File.stat",  "File.stat(dir)",  :dir => tmpdir
  b.iterate "File.ctime", "File.ctime(dir)", :dir => tmpdir
  b.iterate "File.mtime", "File.mtime(dir)", :dir => tmpdir
end
