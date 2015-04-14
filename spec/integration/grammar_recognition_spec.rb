require 'spec_helper'

describe 'speech recognition with a grammar' do
  let(:recordable) { Pocketsphinx::AudioFile.new('spec/assets/audio/goforward.raw') }

  subject do
    Pocketsphinx::SpeechRecognizer.new(@configuration).tap do |speech_recognizer|
      speech_recognizer.recordable = recordable
      speech_recognizer.decoder = @decoder
    end
  end

  # Share decoder across all examples for speed
  before :all do
    @configuration = Pocketsphinx::Configuration::Grammar.new('spec/assets/grammars/goforward.gram')
    @decoder = Pocketsphinx::Decoder.new(@configuration)
  end

  describe '#recognize' do
    it 'should decode speech in raw audio' do
      expect { |b| subject.recognize(2048, &b) }.to yield_with_args("go forward ten meters")
    end
  end
end
