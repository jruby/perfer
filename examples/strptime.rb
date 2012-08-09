require 'date'

Perfer.session "DateTime.strptime" do |s|
  s.iterate :strptime do
    DateTime.strptime("27/Nov/2007:15:01:43 -0800", "%d/%b/%Y:%H:%M:%S %z")
  end
end
