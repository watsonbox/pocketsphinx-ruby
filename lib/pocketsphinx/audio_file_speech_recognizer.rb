module Pocketsphinx
  # High-level class for live speech recognition from a raw audio file.
  class AudioFileSpeechRecognizer < SpeechRecognizer
    def recognize(file_path, max_samples = 2048)
      self.recordable = AudioFile.new(file_path)

      super(max_samples) do |speech|
        yield speech if block_given?
      end
    end
  end
end
