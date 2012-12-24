Perfer.session "#iterate overhead" do |b|
  b.iterate "Simple block" do
    0
  end

  b.iterate "String for eval", "0"
end
