require 'spec_helper'

describe SpeechRecognizer do
  let(:configuration) { double }
  let(:recordable) { double }
  let(:decoder) { double }
  subject { SpeechRecognizer.new(configuration) }

  before do
    subject.decoder = decoder
    subject.recordable = recordable
  end

  describe '#reconfigure' do
    before do
      allow(decoder).to receive(:reconfigure)
      allow(decoder).to receive(:start_utterance)
    end

    it 'saves the configuration if one is given' do
      subject.reconfigure(:new_configuration)
      expect(subject.configuration).to eq(:new_configuration)
    end

    it 'reconfigures the decoder' do
      expect(decoder).to receive(:reconfigure).with(nil).ordered
      expect(decoder).to receive(:reconfigure).with(:new_configuration).ordered

      subject.reconfigure
      subject.reconfigure(:new_configuration)
    end

    it 'restarts an utterance if recognition was interrupted' do
      expect(subject).to receive(:recognizing?).and_return(true)
      expect(decoder).to receive(:start_utterance)

      subject.reconfigure
    end
  end
end
