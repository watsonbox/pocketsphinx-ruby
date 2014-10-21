module Pocketsphinx
  module Configuration
    class SettingDefinition < Struct.new(:name, :type_code, :deflt, :doc)
      TYPES = [:integer, :float, :string, :boolean, :string_list]

      def type
        # Remove the required bit if it exists and find type from log2 of code
        TYPES[Math.log2(type_code - type_code%2) - 1]
      end

      # Convert string defaults from pocketsphinx to Ruby types
      def default
        case type
          when :integer then deflt.to_i
          when :float then deflt.to_f
          when :boolean then deflt == 'yes'
          else deflt
        end
      end

      def required?
        type_code % 2 == 1
      end

      # Build setting definitions from pocketsphinx argument definitions
      #
      # @param [FFI::Pointer] ps_arg_defs A pointer to the Pocketsphinx argument definitions
      #
      # @return [Hash] A hash of setting definitions (name -> definition)
      def self.from_arg_defs(ps_arg_defs)
        {}.tap do |setting_defs|
          arg_array = FFI::Pointer.new(API::Sphinxbase::Argument, ps_arg_defs)

          0.upto(Float::INFINITY) do |i|
            arg = API::Sphinxbase::Argument.new(arg_array[i])
            break if arg[:name].nil?

            # Remove '-' from argument name
            name = arg[:name][1..-1]
            setting_defs[name] = new(name, arg[:type], arg[:deflt], arg[:doc])
          end
        end
      end
    end
  end
end
