require 'pocketsphinx/configuration/setting_definition'

module Pocketsphinx
  class Configuration
    attr_reader :ps_config

    private_class_method :new

    def initialize(ps_arg_defs)
      @ps_arg_defs = ps_arg_defs
      @setting_definitions = SettingDefinition.from_arg_defs(ps_arg_defs)

      # Sets default settings based on definitions
      @ps_config = API::Sphinxbase.cmd_ln_parse_r(nil, ps_arg_defs, 0, nil, 1)

      # Sets default grammar and language model if they are not set explicitly and
      # are present in the default search path.
      API::Pocketsphinx.ps_default_search_args(@ps_config)
    end

    def self.default
      new(API::Pocketsphinx.ps_args)
    end

    def [](name)
      unless definition = @setting_definitions[name]
        raise "Configuration setting '#{name}' does not exist"
      end

      case definition.type
      when :integer
        API::Sphinxbase.cmd_ln_int_r(@ps_config, "-#{name}")
      when :float
        API::Sphinxbase.cmd_ln_float_r(@ps_config, "-#{name}")
      when :string
        API::Sphinxbase.cmd_ln_str_r(@ps_config, "-#{name}")
      when :boolean
        API::Sphinxbase.cmd_ln_int_r(@ps_config, "-#{name}") != 0
      when :string_list
        raise NotImplementedException
      end
    end

    def []=(name, value)
      unless definition = @setting_definitions[name]
        raise "Configuration setting '#{name}' does not exist"
      end

      case definition.type
      when :integer
        raise "Configuration setting '#{name}' must be a Fixnum" unless value.respond_to?(:to_i)
        API::Sphinxbase.cmd_ln_set_int_r(@ps_config, "-#{name}", value.to_i)
      when :float
        raise "Configuration setting '#{name}' must be a Float" unless value.respond_to?(:to_i)
        API::Sphinxbase.cmd_ln_set_float_r(@ps_config, "-#{name}", value.to_f)
      when :string
        API::Sphinxbase.cmd_ln_set_str_r(@ps_config, "-#{name}", value.to_s)
      when :boolean
        API::Sphinxbase.cmd_ln_set_int_r(@ps_config, "-#{name}", value ? 1 : 0)
      when :string_list
        raise NotImplementedException
      end
    end
  end
end
