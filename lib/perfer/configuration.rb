module Perfer
  class Configuration
    DEFAULTS = {
      :minimal_time => 1.0,
      :measurements => 10
    }.freeze

    PROPERTIES = DEFAULTS.keys

    PROPERTIES.each { |property| attr_accessor property }

    def initialize
      @config_file = DIR/'config.yml'

      DEFAULTS.each_pair { |property, value|
        instance_variable_set(:"@#{property}", value)
      }

      if @config_file.exist? and !@config_file.empty?
        YAML.load_file(@config_file).each_pair { |property, value|
          property = property.to_sym
          if PROPERTIES.include? property
            instance_variable_set(:"@#{property}", value)
          else
            warn "Unknown property in configuration file: #{property}"
          end
        }
      end
    end

    def write_defaults
      @config_file.write YAML.dump DEFAULTS
    end

    def to_hash
      PROPERTIES.each_with_object({}) { |property, h|
        h[property] = instance_variable_get(:"@#{property}")
      }
    end
  end
end
