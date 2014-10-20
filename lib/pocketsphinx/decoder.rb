module Pocketsphinx
  class Decoder
    Error = Class.new(StandardError)

    attr_reader :ps_decoder
    attr_writer :ps_api

    def initialize(configuration)
      @configuration = configuration
      @ps_decoder = ps_api.ps_init(configuration.ps_config)
    end

    # Decode a raw audio stream, opening a file if path given
    #
    # See #decode_raw
    #
    # @param [IO] audio_path_or_file The raw audio stream or file path to decode as a single utterance
    # @param [Fixnum] max_samples The maximum samples to process from the stream on each iteration
    def decode(audio_path_or_file, max_samples = 2048)
      case audio_path_or_file
      when String
        File.open(audio_path_or_file, 'rb') { |f| decode_raw(f, max_samples) }
      else
        decode_raw(audio_path_or_file, max_samples)
      end
    end

    # Decode a raw audio stream.
    #
    # No headers are recognized in this files.  The configuration parameters samprate
    # and input_endian are used to determine the sampling rate and endianness of the stream,
    # respectively.  Audio is always assumed to be 16-bit signed PCM.
    #
    # @param [IO] audio_file The raw audio stream to decode as a single utterance
    # @param [Fixnum] max_samples The maximum samples to process from the stream on each iteration
    def decode_raw(audio_file, max_samples = 2048)
      start_utterance

      FFI::MemoryPointer.new(:int16, max_samples) do |buffer|
        while data = audio_file.read(max_samples * 2)
          buffer.write_string(data)
          process_raw(buffer, data.length / 2)
        end
      end

      end_utterance
    end

    # Decode raw audio data.
    #
    # @param [Boolean] no_search If non-zero, perform feature extraction but don't do any
    #   recognition yet.  This may be necessary if your processor has trouble doing recognition in
    #   real-time.
    # @param [Boolean] full_utt If non-zero, this block of data is a full utterance
    #   worth of data.  This may allow the recognizer to produce more accurate results.
    # @return Number of frames of data searched
    def process_raw(buffer, size, no_search = false, full_utt = false)
      ps_api.ps_process_raw(@ps_decoder, buffer, size, no_search ? 1 : 0, full_utt ? 1 : 0).tap do |result|
        raise Error, "Decoder#process_raw failed with error code #{result}" if result < 0
      end
    end

    # Start utterance processing.
    #
    # This function should be called before any utterance data is passed
    # to the decoder.  It marks the start of a new utterance and
    # reinitializes internal data structures.
    #
    # @param [String] name String uniquely identifying this utterance. If nil, one will be created.
    def start_utterance(name = nil)
      ps_api.ps_start_utt(@ps_decoder, name).tap do |result|
        raise Error, "Decoder#start_utterance failed with error code #{result}" if result < 0
      end
    end

    # End utterance processing
    def end_utterance
      ps_api.ps_end_utt(@ps_decoder).tap do |result|
        raise Error, "Decoder#end_utterance failed with error code #{result}" if result < 0
      end
    end

    # Checks if the last feed audio buffer contained speech
    def in_speech?
      ps_api.ps_get_in_speech(@ps_decoder) != 0
    end

    # Get hypothesis string and path score.
    #
    # @return [String] Hypothesis string
    # @todo Expand to return path score and utterance ID
    def hypothesis
      ps_api.ps_get_hyp(@ps_decoder, nil, nil)
    end

    def ps_api
      @ps_api || API::Pocketsphinx
    end
  end
end
