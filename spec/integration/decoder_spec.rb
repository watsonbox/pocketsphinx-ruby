require 'spec_helper'

describe Pocketsphinx::Decoder do
  subject { @decoder }
  let(:configuration) { @configuration }

  # Share decoder across all examples for speed
  before :all do
    @configuration = Pocketsphinx::Configuration.default
    @decoder = Pocketsphinx::Decoder.new(@configuration)
  end

  describe '#decode' do
    it 'correctly decodes the speech in goforward.raw' do
      @decoder.ps_api = nil
      subject.decode File.open('spec/assets/audio/goforward.raw', 'rb')

      expect(subject.hypothesis).to eq("go forward ten meters")
    end

    it 'accepts a file path as well as a stream' do
      subject.decode 'spec/assets/audio/goforward.raw'
      expect(subject.hypothesis).to eq("go forward ten meters")
    end

    it 'reports words with start/end frame values' do
      @decoder.ps_api = nil
      subject.decode File.open('spec/assets/audio/goforward.raw', 'rb')

      expect(subject.words.map(&:word)).to eq(["<s>", "go", "forward", "ten", "meters", "</s>"])
      expect(subject.words.map(&:start_frame)).to eq([608, 611, 623, 676, 712, 771])
      expect(subject.words.map(&:end_frame)).to eq([610, 622, 675, 711, 770, 821])
    end
  end
end
