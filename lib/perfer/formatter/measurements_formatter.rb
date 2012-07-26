module Perfer
  class MeasurementsFormatter
    include Formatter

    SEPARATOR = '  '

    def initialize(measurements)
      @measurements = measurements
      @fields = Perfer::TIMES_FIELDS.dup
      @fields.reject! { |field|
        measurements.none? { |m| m.key? field }
      }
    end

    def report
      puts @fields.map { |field| field.to_s.center(8) }.join(SEPARATOR).rstrip
      @measurements.each { |m|
        puts @fields.map { |field| format_duration(m[field] || 0) }.join(SEPARATOR)
      }
    end
  end
end