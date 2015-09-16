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

      expect(subject.hypothesis.path_score).to be_within(0.01).of(0.4651996053749572)
      expect(subject.hypothesis.posterior_prob).to be_within(0.01).of(0.0018953977306176936)
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
      expect(subject.words.map(&:start_frame)).to eq([2, 48, 66, 119, 155, 214])
      expect(subject.words.map(&:end_frame)).to eq([47, 65, 118, 154, 213, 262])

      expected_pps = [1.0, 0.9, 0.9, 0.1, 0.29, 1.0]
      subject.words.map(&:posterior_prob).each_with_index do |pp, index|
        expect(pp).to be_within(0.1).of(expected_pps[index])
      end

      expected_ls = [1.0, 0.95, 0.95, 0.94, 0.95, 0.98]
      subject.words.map(&:language_score).each_with_index do |ls, index|
        expect(ls).to be_within(0.1).of(expected_ls[index])
      end
    end
  end
end
