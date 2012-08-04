module Perfer
  class Configuration
    DEFAULTS = {
      :minimal_time => 1.0,
      :measurements => 10
    }.freeze

    DEFAULTS.each_key { |property| attr_accessor property }

    def initialize
      @config_file = DIR/'config.yml'

      DEFAULTS.each_pair { |key, value|
        instance_variable_set(:"@#{key}", value)
      }

      if @config_file.exist? and !@config_file.empty?
        YAML.load_file(@config_file).each_pair { |key, value|
          key = key.to_sym
          if DEFAULTS.key? key
            instance_variable_set(:"@#{key}", value)
          else
            warn "Unknown property in configuration file: #{key}"
          end
        }
      end
    end

    def write_defaults
      @config_file.write YAML.dump DEFAULTS
    end

    def to_hash
      instance_variables.each_with_object({}) { |ivar, h|
        h[ivar.to_s[1..-1].to_sym] = instance_variable_get(ivar)
      }
    end
  end
end
