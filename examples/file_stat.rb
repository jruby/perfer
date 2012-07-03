require 'tmpdir'
tmpdir = Dir.tmpdir

Perfer.session "File.stat" do |b|
  b.iterate "File.stat" do
    File.stat(tmpdir)
  end

  b.iterate "File.ctime" do
    File.ctime(tmpdir)
  end

  b.iterate "File.mtime" do
    File.mtime(tmpdir)
  end
end
