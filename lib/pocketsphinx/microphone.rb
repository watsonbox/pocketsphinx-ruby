module Pocketsphinx
  # Provides non-blocking live audio recording using libsphinxad
  #
  # Implements Recordable interface (#start_recording, #stop_recording and #read_audio)
  class Microphone
    include API::CallHelpers

    attr_reader :ps_audio_device
    attr_writer :ps_api
    attr_reader :sample_rate

    # Opens an audio device for recording
    #
    # The device is opened in non-blocking mode and placed in idle state.
    #
    # @param [Fixnum] sample_rate Samples per second for recording, e.g. 16000 for 16kHz
    # @param [String] default_device The device name
    # @param [Object] ps_api A SphinxAD API implementation to use, API::SphinxAD if not provided
    def initialize(sample_rate = 16000, default_device = nil, ps_api = nil)
      @sample_rate = sample_rate
      @ps_api = ps_api
      @ps_audio_device = self.ps_api.ad_open_dev(default_device, sample_rate)

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
      api_call :ad_start_rec, @ps_audio_device
    end

    def stop_recording
      api_call :ad_stop_rec, @ps_audio_device
    end

    # Read next block of audio samples while recording; read upto max samples into buf.
    #
    # @param [FFI::Pointer] buffer 16bit buffer of at least max_samples in size
    # @params [Fixnum] max_samples The maximum number of samples to read from the audio device
    # @return [Fixnum] Samples actually read (could be 0 since non-blocking); nil if not
    #   recording and no more samples remaining to be read from most recent recording.
    def read_audio(buffer, max_samples = 2048)
      samples = ps_api.ad_read(@ps_audio_device, buffer, max_samples)
      samples if samples >= 0
    end

    # A Recordable may specify an audio reading delay
    #
    # In the case of the Microphone, because we are doing non-blocking reads,
    # we specify a delay which should fill half of the max buffer size
    #
    # @param [Fixnum] max_samples The maximum samples we tried to read from the audio device
    def read_audio_delay(max_samples = 2048)
      max_samples.to_f / (2 * sample_rate)
    end

    def close_device
      api_call :ad_close, @ps_audio_device
    end

    def ps_api
      @ps_api || API::SphinxAD
    end
  end
end
