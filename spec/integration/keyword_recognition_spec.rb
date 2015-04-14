require 'spec_helper'

# Keyword spotting recognizes keywords mid-speech, not only after a speech -> silence transition
describe 'keyword spotting' do
  let(:recordable) { Pocketsphinx::AudioFile.new('spec/assets/audio/goforward.raw') }

  subject do
    Pocketsphinx::SpeechRecognizer.new(@configuration).tap do |speech_recognizer|
      speech_recognizer.recordable = recordable
      speech_recognizer.decoder = @decoder
    end
  end

  # Share decoder across all examples for speed
  before :all do
    @configuration = Pocketsphinx::Configuration::KeywordSpotting.new('forward')
    @decoder = Pocketsphinx::Decoder.new(@configuration)
  end

  describe '#recognize' do
    it 'should decode speech in raw audio' do
      expect { |b| subject.recognize(2048, &b) }.to yield_with_args('forward')
    end
  end
end
