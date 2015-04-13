require 'spec_helper'

describe 'speech recognition with default configuration' do
  subject do
    Pocketsphinx::AudioFileSpeechRecognizer.new.tap do |speech_recognizer|
      speech_recognizer.decoder = @decoder
    end
  end

  # Share decoder across all examples for speed
  before :all do
    @decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
  end

  describe '#recognize' do
    it 'should decode speech in raw audio' do
      expect { |b| subject.recognize('spec/assets/audio/goforward.raw', 2048, &b) }.
        to yield_with_args("go forward ten meters")
    end
  end
end
