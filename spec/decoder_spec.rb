require 'spec_helper'

describe Decoder do
  subject { @decoder }

  # Share decoder across all examples for speed
  before :all do
    @decoder = Decoder.new(Configuration.default)
  end

  describe '#process_raw' do
    it 'calls libpocketsphinx' do
      FFI::MemoryPointer.new(:int16, 4096) do |buffer|
        expect(API::Pocketsphinx)
          .to receive(:ps_process_raw)
          .with(subject.ps_decoder, buffer, 4096, 0, 0)
          .and_return(0)

        subject.process_raw(buffer, 4096, false, false)
      end
    end

    it 'raises an exception on error' do
      FFI::MemoryPointer.new(:int16, 4096) do |buffer|
        expect(API::Pocketsphinx)
          .to receive(:ps_process_raw)
          .with(subject.ps_decoder, buffer, 4096, 0, 0)
          .and_return(-1)

        expect { subject.process_raw(buffer, 4096, false, false) }
          .to raise_exception "Decoder#process_raw failed with error code -1"
      end
    end
  end

  describe '#start_utterance' do
    it 'calls libpocketsphinx' do
      expect(API::Pocketsphinx)
        .to receive(:ps_start_utt)
        .with(subject.ps_decoder, "Utterance Name")
        .and_return(0)

      subject.start_utterance("Utterance Name")
    end

    it 'raises an exception on error' do
      expect(API::Pocketsphinx)
        .to receive(:ps_start_utt)
        .with(subject.ps_decoder, "Utterance Name")
        .and_return(-1)

      expect { subject.start_utterance("Utterance Name") }
        .to raise_exception "Decoder#start_utterance failed with error code -1"
    end
  end

  describe '#end_utterance' do
    it 'calls libpocketsphinx' do
      expect(API::Pocketsphinx)
        .to receive(:ps_end_utt)
        .with(subject.ps_decoder)
        .and_return(0)

      subject.end_utterance
    end

    it 'raises an exception on error' do
      expect(API::Pocketsphinx)
        .to receive(:ps_end_utt)
        .with(subject.ps_decoder)
        .and_return(-1)

      expect { subject.end_utterance }
        .to raise_exception "Decoder#end_utterance failed with error code -1"
    end
  end

  describe '#in_speech' do
    it 'calls libpocketsphinx' do
      expect(API::Pocketsphinx)
        .to receive(:ps_get_in_speech)
        .with(subject.ps_decoder)
        .and_return(0)

      expect(subject.in_speech?).to eq(false)
    end
  end

  describe '#hypothesis' do
    it 'calls libpocketsphinx' do
      expect(API::Pocketsphinx)
        .to receive(:ps_get_hyp)
        .with(subject.ps_decoder, nil, nil)
        .and_return("Hypothesis")

      expect(subject.hypothesis).to eq("Hypothesis")
    end
  end
end
