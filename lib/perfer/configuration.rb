module Perfer
  class Configuration
    DEFAULTS = {
      :minimal_time => 1.0,
      :measurements => 10
    }.freeze

    def initialize
      @config_file = DIR/'config.yml'

      DEFAULTS.each_key { |key|
        instance_variable_set(:"@#{key}", DEFAULTS[key])
        self.class.send :attr_accessor, key
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
  end
end
