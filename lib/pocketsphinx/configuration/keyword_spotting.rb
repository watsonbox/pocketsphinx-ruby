module Pocketsphinx
  module Configuration
    class KeywordSpotting < Default
      attr_reader :kws_threshold

      def initialize(keyword, threshold = nil)
        super()

        self['lm'] = nil
        self.keyword = keyword
        self.kws_threshold = threshold if threshold
      end

      def keyword
        self['keyphrase']
      end

      def keyword=(value)
        self['keyphrase'] = sanitize_keyword value
      end

      def kws_threshold
        self['kws_threshold']
      end

      def kws_threshold=(value)
        self['kws_threshold'] = value
      end

      # See SpeechRecognizer#algorithm
      def recognition_algorithm
        :continuous
      end

      private

      def sanitize_keyword(keyword)
        keyword.downcase
      end
    end
  end
end
