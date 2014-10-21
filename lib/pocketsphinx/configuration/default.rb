module Pocketsphinx
  module Configuration
    class Default < Base
      def initialize
        super

        # Sets default grammar and language model if they are not set explicitly and
        # are present in the default search path.
        API::Pocketsphinx.ps_default_search_args(@ps_config)
      end
    end

    def self.default
      Default.new
    end
  end
end
