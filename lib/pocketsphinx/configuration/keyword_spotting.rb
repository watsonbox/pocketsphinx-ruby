module Pocketsphinx
  module Configuration
    class KeywordSpotting < Default
      def initialize(keyword, threshold = nil)
        super()

        self['lm'] = nil
        self['keyphrase'] = sanitize_keyword keyword
        self['kws_threshold'] = threshold if threshold
      end

      private

      def sanitize_keyword(keyword)
        keyword.downcase
      end
    end
  end
end
