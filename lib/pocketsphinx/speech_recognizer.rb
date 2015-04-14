module Pocketsphinx
  # Reads audio data from a recordable interface and decodes it into utterances
  #
  # Essentially orchestrates interaction between Recordable and Decoder, and detects new utterances.
  class SpeechRecognizer
    # Recordable interface must implement #start_recording, #stop_recording and #read_audio
    attr_writer :recordable
    attr_writer :decoder
    attr_writer :configuration

    ALGORITHMS = [:after_speech, :continuous]

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

      pause do
        decoder.reconfigure(configuration)
      end
    end

    # Recognize speech and yield hypotheses in infinite loop
    #
    # @param [Fixnum] max_samples Number of samples to process at a time
    def recognize(max_samples = 2048, &b)
      unless ALGORITHMS.include?(algorithm)
        raise NotImplementedError, "Unknown speech recognition algorithm: #{algorithm}"
      end

      start unless recognizing?

      FFI::MemoryPointer.new(:int16, max_samples) do |buffer|
        loop do
          send("recognize_#{algorithm}", max_samples, buffer, &b) or break
        end
      end
    ensure
      stop
    end

    def in_speech?
      # Use Pocketsphinx's implementation by default
      decoder.in_speech?
    end

    def recognizing?
      @recognizing == true
    end

    def pause
      recognizing?.tap do |was_recognizing|
        stop if was_recognizing
        yield
        start if was_recognizing
      end
    end

    def start
      recordable.start_recording
      decoder.start_utterance
      @recognizing = true
    end

    def stop
      decoder.end_utterance
      recordable.stop_recording
      @recognizing = false
    end

    # Determine which algorithm to use for co-ordinating speech recognition
    #
    # @return [Symbol] :continuous or :after_speech
    # :continuous yields as soon as any hypothesis is available
    # :after_speech yields hypothesis on speech -> silence transition if one exists
    # Default is :after_speech
    def algorithm
      if configuration.respond_to?(:recognition_algorithm)
        configuration.recognition_algorithm
      else
        ALGORITHMS.first
      end
    end

    private

    # Yields as soon as any hypothesis is available
    def recognize_continuous(max_samples, buffer)
      process_audio(buffer, max_samples).tap do
        if hypothesis = decoder.hypothesis
          yield hypothesis

          decoder.end_utterance
          decoder.start_utterance
        end
      end
    end

    # Splits speech into utterances by detecting silence between them.
    # By default this uses Pocketsphinx's internal Voice Activity Detection (VAD) which can be
    # configured by adjusting the `vad_postspeech`, `vad_prespeech`, and `vad_threshold` settings.
    def recognize_after_speech(max_samples, buffer)
      if in_speech?
        while in_speech?
          process_audio(buffer, max_samples) or break
        end

        decoder.end_utterance
        hypothesis = decoder.hypothesis
        decoder.start_utterance

        yield hypothesis if hypothesis
      end

      process_audio(buffer, max_samples)
    end

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
  end
end
