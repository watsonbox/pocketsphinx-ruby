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
  end
end
