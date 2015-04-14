require 'spec_helper'

describe Pocketsphinx::Decoder do
  subject { @decoder }
  let(:configuration) { @configuration }

  # Share decoder across all examples for speed
  before do
    @configuration = Pocketsphinx::Configuration.default
    @decoder = Pocketsphinx::Decoder.new(@configuration)
  end

  it 'reads cmninit configuration values from default acoustic model feat.params' do
    expect(configuration.details('cmninit')[:default]).to eq("8.0")
    expect(configuration.details('cmninit')[:value]).to eq("40,3,-1")
  end

  describe '#decode' do
    it 'correctly decodes the speech in goforward.raw' do
      subject.decode File.open('spec/assets/audio/goforward.raw', 'rb')
      expect(subject.hypothesis).to eq("go forward ten meters")
    end

    # FIXME: This test illustrates a current issue discussed in:
    #        https://github.com/watsonbox/pocketsphinx-ruby/issues/10
    it 'incorrectly decodes the speech in hello.wav on first attempt' do
      hypotheses = (1..2).map do
        subject.decode File.open('spec/assets/audio/hello.wav', 'rb')
        subject.hypothesis
      end

      expect(hypotheses).to eq(['oh', 'hello'])
    end

    it 'accepts a file path as well as a stream' do
      subject.decode 'spec/assets/audio/goforward.raw'
      expect(subject.hypothesis).to eq("go forward ten meters")
    end

    it 'reports words with start/end frame values' do
      subject.decode File.open('spec/assets/audio/goforward.raw', 'rb')

      expect(subject.words.map(&:word)).to eq(["<s>", "go", "forward", "ten", "meters", "</s>"])
      expect(subject.words.map(&:start_frame)).to eq([0, 46, 64, 117, 153, 212])
      expect(subject.words.map(&:end_frame)).to eq([45, 63, 116, 152, 211, 260])
    end
  end
end
