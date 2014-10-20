module Pocketsphinx
  # High-level class for live speech recognition.
  #
  # Modeled on the LiveSpeechRecognizer from Sphinx4.
  class LiveSpeechRecognizer < SpeechRecognizer
    def recordable
      @recordable ||= Microphone.new
    end
  end
end
