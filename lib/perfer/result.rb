module Perfer
  # A result for a particular job run
  class Result
    extend Forwardable

    attr_reader :metadata
    attr_accessor :data
    def initialize(metadata, data = [])
      @metadata = metadata.dup
      @data = data
    end

    def_delegators :@data, :<<, :size, :length, :each
    def_delegators :@metadata, :[], :[]=

    def stats
      Statistics.new(on(:real))
    end

    def on(field)
      @data.map { |result| result[field] }
    end

    def to_hash
      { :metadata => @metadata, :data => @data }
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
