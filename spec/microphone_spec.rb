require 'spec_helper'

describe Pocketsphinx::Microphone do
  module DummyAPI
    def self.ad_open_dev(default_device, sample_rate)
      :audio_device
    end
  end

  subject { @microphone }
  let!(:ps_api) { @microphone.ps_api = double }

  # Share microphone across all examples for speed
  before :all do
    # Don't open an audio device as there isn't one on Travis CI
    @microphone = Pocketsphinx::Microphone.new(16000, nil, DummyAPI)
  end

  describe '#start_recording' do
    it 'calls libsphinxad' do
      expect(ps_api)
        .to receive(:ad_start_rec)
        .with(subject.ps_audio_device)
        .and_return(0)

      subject.start_recording
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ad_start_rec)
        .with(subject.ps_audio_device)
        .and_return(-1)

      expect { subject.start_recording }
        .to raise_exception "Microphone#start_recording failed with error code -1"
    end
  end

  describe '#stop_recording' do
    it 'calls libsphinxad' do
      expect(ps_api)
        .to receive(:ad_stop_rec)
        .with(subject.ps_audio_device)
        .and_return(0)

      subject.stop_recording
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ad_stop_rec)
        .with(subject.ps_audio_device)
        .and_return(-1)

      expect { subject.stop_recording }
        .to raise_exception "Microphone#stop_recording failed with error code -1"
    end
  end

  describe '#record' do
    it 'starts and stops recording, yielding control' do
      expect(subject).to receive(:start_recording).ordered

      subject.record do
        expect(subject).to receive(:stop_recording).ordered
      end
    end
  end

  describe '#read_audio' do
    it 'calls libsphinxad' do
      expect(ps_api)
        .to receive(:ad_read)
        .with(subject.ps_audio_device, :buffer, 2048)
        .and_return(0)

      subject.read_audio(:buffer, 2048)
    end
  end

  describe '#read_audio_delay' do
    it 'should be 0.064 seconds for a max_samples of 2048 and sample rate of 16kHz' do
      expect(subject.read_audio_delay(2048)).to eq(0.064)
    end
  end

  describe '#close_device' do
    it 'calls libsphinxad' do
      expect(ps_api)
        .to receive(:ad_close)
        .with(subject.ps_audio_device)
        .and_return(0)

      subject.close_device
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ad_close)
        .with(subject.ps_audio_device)
        .and_return(-1)

      expect { subject.close_device }
        .to raise_exception "Microphone#close_device failed with error code -1"
    end
  end
end
