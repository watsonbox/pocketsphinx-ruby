module Pocketsphinx
  # High-level class for live speech recognition.
  #
  # Modeled on the LiveSpeechRecognizer from Sphinx4.
  class LiveSpeechRecognizer < SpeechRecognizer
    attr_writer :microphone

    def microphone
      @microphone ||= Microphone.new
    end

    # Recognize utterances and yield hypotheses in infinite loop
    #
    # @param [Float]
    def recognize(recording_interval = 0.1, max_samples = 4096)
      decoder.start_utterance

      microphone.record do
        FFI::MemoryPointer.new(:int16, max_samples) do |buffer|
          loop do
            if decoder.in_speech?
              process_audio(buffer, max_samples, recording_interval) while decoder.in_speech?
              yield get_hypothesis
            else
              process_audio(buffer, max_samples, recording_interval)
            end
          end
        end
      end
    end

    private

    def process_audio(buffer, max_samples, delay)
      sample_count = microphone.read_audio(buffer, max_samples)
      decoder.process_raw(buffer, sample_count)
      sleep delay
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
