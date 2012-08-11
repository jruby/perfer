Perfer.session "#iterate overhead" do |b|
  b.iterate "Simple block" do
    0
  end

  b.iterate "Block with given argument" do |n|
    i = 0
    while i < n
      0
      i += 1
    end
  end

  b.iterate "String for eval", "0"
end
