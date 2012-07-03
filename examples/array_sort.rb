Perfer.session "Array#sort" do |b|
  b.bench "Array#sort" do |n|
    ary = Array.new(n) { rand(n) }

    b.measure do
      ary.sort
    end
  end

  b.bench "Array#sort!" do |n|
    ary = Array.new(n) { rand(n) }

    b.measure do
      ary.sort!
    end
  end
end
