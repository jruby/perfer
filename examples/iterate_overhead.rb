Perfer.session "#iterate overhead" do |b|
  b.iterate "Simple block" do
  end

  b.iterate "Block with given argument" do |n|
    i = 0
    while i < n
      i += 1
    end
  end

  b.iterate "String for eval", ""
end
