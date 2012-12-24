require 'tmpdir'
tmpdir = Dir.tmpdir

Perfer.session "File.stat" do |b|
  b.iterate "Simple block" do
    File.stat(tmpdir)
  end

  b.iterate "String for eval", "File.stat(tmpdir)", :tmpdir => tmpdir
end
