require 'spec_helper'

describe Microphone do
  subject { @microphone }
  let!(:ps_api) { @microphone.ps_api = double }

  # Share microphone across all examples for speed
  before :all do
    @microphone = Microphone.new
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
        .with(subject.ps_audio_device, :buffer, 4096)
        .and_return(0)

      subject.read_audio(:buffer, 4096)
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
