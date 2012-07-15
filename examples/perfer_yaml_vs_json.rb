require 'json'

Perfer.session "YAML vs JSON for Perfer Result" do |s|
  data = 100.times.map {
    Perfer::Result.new(s.metadata).tap { |r|
      10.times {
        r << Perfer.measure {}
      }
    }
  }
  yaml = YAML.dump(data)
  yaml_stream = YAML.dump_stream(*data)
  json = JSON.dump(data)

  s.iterate "YAML.dump" do
    YAML.dump(data)
  end
  s.iterate "YAML.load" do
    YAML.load(yaml)
  end

  s.iterate "YAML.dump_stream" do
    YAML.dump_stream(*data)
  end
  s.iterate "YAML.load_stream" do
    YAML.load_stream(yaml_stream)
  end

  s.iterate "JSON.dump" do
    JSON.dump(data)
  end
  s.iterate "JSON.load" do
    JSON.load(json)
  end
end
