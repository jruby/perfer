module Perfer
  # A result for a particular job run
  class Result
    attr_reader :metadata
    attr_accessor :data
    def initialize(metadata, data = [])
      @metadata = metadata.dup
      @data = data
    end

    %w[<< size length].each do |meth|
      class_eval "def #{meth}; @data.#{meth}; end"
    end

    def each(&block)
      @data.each(&block)
    end

    def [](field)
      @metadata[field]
    end

    def []=(field, value)
      @metadata[field] = value
    end

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
