module Pocketsphinx
  class SpeechRecognizer
    attr_reader :decoder

    def initialize(configuration= nil)
      @decoder = Decoder.new(configuration || Configuration.default)
    end
  end
end
