module Pocketsphinx
  # Reads audio data from a recordable interface and decodes it into utterances
  #
  # Essentially orchestrates interaction between Recordable and Decoder, and detects new utterances.
  class SpeechRecognizer
    # Recordable interface must implement #record and #read_audio
    attr_writer :recordable
    attr_writer :decoder
    attr_writer :configuration

    def initialize(configuration = nil)
      @configuration = configuration
    end

    def recordable
      @recordable or raise "A SpeechRecognizer must have a recordable interface"
    end

    def decoder
      @decoder ||= Decoder.new(configuration)
    end

    def configuration
      @configuration ||= Configuration.default
    end

    # Reinitialize the decoder with updated configuration.
    #
    # See Decoder#reconfigure
    #
    # @param [Configuration] configuration An optional new configuration to use.  If this is
    #   nil, the previous configuration will be reloaded, with any changes applied.
    def reconfigure(configuration = nil)
      self.configuration = configuration if configuration

      decoder.reconfigure(configuration)
      decoder.start_utterance if recognizing?
    end

    # Recognize utterances and yield hypotheses in infinite loop
    #
    # Splits speech into utterances by detecting silence between them.
    # By default this uses Pocketsphinx's internal Voice Activity Detection (VAD) which can be
    # configured by adjusting the `vad_postspeech`, `vad_prespeech`, and `vad_threshold` settings.
    #
    # @param [Fixnum] max_samples Number of samples to process at a time
    def recognize(max_samples = 4096)
      decoder.start_utterance
      @recognizing = true

      recordable.record do
        FFI::MemoryPointer.new(:int16, max_samples) do |buffer|
          loop do
            if in_speech?
              while decoder.in_speech?
                process_audio(buffer, max_samples) or break
              end

              hypothesis = get_hypothesis
              yield hypothesis if hypothesis
            else
              process_audio(buffer, max_samples) or break
            end
          end
        end
      end
    ensure
      @recognizing = false
    end

    def in_speech?
      # Use Pocketsphinx's implementation by default
      decoder.in_speech?
    end

    def recognizing?
      @recognizing == true
    end

    private

    def process_audio(buffer, max_samples)
      sample_count = recordable.read_audio(buffer, max_samples)

      if sample_count
        decoder.process_raw(buffer, sample_count)

        # Check for a delay for example in case of non-blocking live audio
        if recordable.respond_to?(:read_audio_delay)
          sleep recordable.read_audio_delay(max_samples)
        end
      end

      sample_count
    end

    # Called on speech -> silence transition
    def get_hypothesis
      decoder.end_utterance
      decoder.hypothesis.tap do
        decoder.start_utterance
      end
    end
  end
end
