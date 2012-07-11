require 'tmpdir'
tmpdir = Dir.tmpdir

Perfer.session "File.stat" do |b|
  b.iterate "Simple block" do
    File.stat(tmpdir)
  end

  b.iterate "Block with given argument" do |n|
    i = 0
    while i < n
      File.stat(tmpdir)
      i += 1
    end
  end

  b.iterate "String for eval", "File.stat(tmpdir)", :tmpdir => tmpdir
end
