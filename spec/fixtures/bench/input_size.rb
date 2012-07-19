Perfer.session "Input size" do |s|
  s.bench 'empty' do |n|
    s.measure {}
  end
  s.bench 'second job' do |n|
    s.measure { nil }
  end
end
