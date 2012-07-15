module Perfer
  # A result for a particular job run
  class Result
    extend Forwardable

    attr_reader :metadata, :data
    def initialize(metadata, data = [])
      @metadata = metadata.dup
      @data = data
    end

    def_instance_delegators :@data,
      :<<, :size, :length, :each

    def_instance_delegators :@metadata, :[], :[]=

    def aggregate
      stats = Statistics.new(on(:real))
      mean = stats.mean
      aggregate = {
        :mean => mean,
        :margin_of_error => stats.margin_of_error
      }
      if @metadata[:iterations]
        aggregate[:ips] = @metadata[:iterations]/mean
      end
      aggregate
    end

    def on(field)
      @data.map { |result| result[field] }
    end

    def to_json(*args)
      {
        'json_class' => self.class.name,
        'data'       => @data,
        'metadata'   => @metadata
      }.to_json(*args)
    end

    def self.json_create json
      new(json['metadata'], json['data'])
    end
  end
end
