module Pocketsphinx
  module Configuration
    class Default < Base
      def initialize
        super

        # Sets default grammar and language model if they are not set explicitly and
        # are present in the default search path.
        API::Pocketsphinx.ps_default_search_args(@ps_config)

        # Treat ps_default_search_args settings as defaults
        changes.each do |details|
          setting_definitions[details[:name]].deflt = details[:value]
        end
      end

      # Show details for settings which don't match Pocketsphinx defaults
      def changes
        details.reject { |d| d[:default] == d[:value] }
      end
    end

    def self.default
      Default.new
    end
  end
end
