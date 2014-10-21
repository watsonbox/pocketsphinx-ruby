require 'spec_helper'

describe SpeechRecognizer do
  let(:recordable) { AudioFile.new('spec/assets/audio/goforward.raw') }

  subject do
    SpeechRecognizer.new.tap do |speech_recognizer|
      speech_recognizer.recordable = recordable
      speech_recognizer.decoder = @decoder
    end
  end

  # Share decoder across all examples for speed
  before :all do
    @decoder = Decoder.new(Configuration.default)
  end

  describe '#recognize' do
    it 'should decode speech in raw audio' do
      expect { |b| subject.recognize(4096, &b) }.to yield_with_args("go forward ten years")
    end
  end
end
