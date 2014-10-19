module Pocketsphinx
  # Provides non-blocking audio recording using libsphinxad
  class Microphone
    Error = Class.new(StandardError)

    attr_reader :ps_audio_device
    attr_writer :ps_api

    # Opens an audio device for recording
    #
    # The device is opened in non-blocking mode and placed in idle state.
    #
    # @param [Fixnum] sample_rate Samples per second for recording, e.g. 16000 for 16kHz
    # @param [String] default_device The device name
    def initialize(sample_rate = 16000, default_device = nil)
      @ps_audio_device = ps_api.ad_open_dev(default_device, sample_rate)

      # Ensure that audio device is closed when object is garbage collected
      ObjectSpace.define_finalizer(self, self.class.finalize(ps_api, @ps_audio_device))
    end

    def self.finalize(ps_api, ps_audio_device)
      proc { ps_api.ad_close(ps_audio_device) }
    end

    def record
      start_recording
      yield
      stop_recording
    end

    def start_recording
      ps_api.ad_start_rec(@ps_audio_device).tap do |result|
        raise Error, "Microphone#start_recording failed with error code #{result}" if result < 0
      end
    end

    def stop_recording
      ps_api.ad_stop_rec(@ps_audio_device).tap do |result|
        raise Error, "Microphone#stop_recording failed with error code #{result}" if result < 0
      end
    end

    # Read next block of audio samples while recording; read upto max samples into buf.
    #
    # @param [FFI::Pointer] buffer 16bit buffer of at least max_samples in size
    # @return [Fixnum] Samples actually read (could be 0 since non-blocking); -1 if not
    #   recording and no more samples remaining to be read from most recent recording.
    def read_audio(buffer, max_samples = 4096)
      ps_api.ad_read(@ps_audio_device, buffer, max_samples)
    end

    def close_device
      ps_api.ad_close(@ps_audio_device).tap do |result|
        raise Error, "Microphone#close_device failed with error code #{result}" if result < 0
      end
    end

    def ps_api
      @ps_api || API::SphinxAD
    end
  end
end
