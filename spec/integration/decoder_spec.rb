require 'spec_helper'

describe Decoder do
  subject { @decoder }
  let(:configuration) { @configuration }

  # Share decoder across all examples for speed
  before :all do
    @configuration = Configuration.default
    @decoder = Decoder.new(@configuration)
  end

  describe '#decode' do
    it 'correctly decodes the speech in goforward.raw' do
      @decoder.ps_api = nil
      subject.decode File.open('spec/assets/audio/goforward.raw', 'rb')

      # With the default configuration (no specific grammar), pocketsphinx doesn't actually
      # get this quite right, but nonetheless this is the expected output
      expect(subject.hypothesis).to eq("go forward ten years")
    end

    it 'accepts a file path as well as a stream' do
      subject.decode 'spec/assets/audio/goforward.raw'
      expect(subject.hypothesis).to eq("go forward ten years")
    end
  end
end
