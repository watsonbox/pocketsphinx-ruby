module Pocketsphinx
  class Decoder
    require 'delegate'

    include API::CallHelpers

    class Hypothesis < SimpleDelegator
      attr_accessor :path_score
      attr_accessor :posterior_prob

      def initialize(string, path_score, posterior_prob = nil)
        @path_score = path_score
        @posterior_prob = posterior_prob

        super(string)
      end
    end

    Word = Struct.new(:word, :start_frame, :end_frame)

    attr_writer :ps_api
    attr_accessor :configuration

    # Initialize a Decoder
    #
    # Note that this initialization process actually updates the Configuration based on settings
    # which are found in feat.params along with the acoustic model.
    #
    # @param [Configuration] configuration
    # @param [FFI::Pointer] ps_decoder An optional Pocketsphinx decoder. One is initialized if not provided.
    def initialize(configuration, ps_decoder = nil)
      @configuration = configuration
      init_decoder if ps_decoder.nil?
    end

    # Reinitialize the decoder with updated configuration.
    #
    # This function allows you to switch the acoustic model, dictionary, or other configuration
    # without creating an entirely new decoding object.
    #
    # @param [Configuration] configuration An optional new configuration to use.  If this is
    #   nil, the previous configuration will be reloaded, with any changes applied.
    def reconfigure(configuration = nil)
      self.configuration = configuration if configuration
      reinit_decoder
    end

    # Decode a raw audio stream as a single utterance, opening a file if path given
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

    # Decode a raw audio stream as a single utterance.
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
      api_call :ps_process_raw, ps_decoder, buffer, size, no_search ? 1 : 0, full_utt ? 1 : 0
    end

    # Start utterance processing.
    #
    # This function should be called before any utterance data is passed
    # to the decoder.  It marks the start of a new utterance and
    # reinitializes internal data structures.
    def start_utterance
      api_call :ps_start_utt, ps_decoder
    end

    # End utterance processing
    def end_utterance
      api_call :ps_end_utt, ps_decoder
    end

    # Checks if the last feed audio buffer contained speech
    def in_speech?
      ps_api.ps_get_in_speech(ps_decoder) != 0
    end

    # Get hypothesis string (with #path_score and #utterance_id).
    #
    # @return [Hypothesis] Hypothesis (behaves like a string)
    def hypothesis
      mp_path_score = FFI::MemoryPointer.new(:int32, 1)
      logmath = ps_api.ps_get_logmath(ps_decoder)

      hypothesis = ps_api.ps_get_hyp(ps_decoder, mp_path_score)
      posterior_prob = ps_api.logmath_exp(logmath, mp_path_score.get_int32(0))

      hypothesis.nil? ? nil : Hypothesis.new(
        hypothesis,
        mp_path_score.get_int32(0),
        posterior_prob
      )
    end

    # Get an array of words with start/end frame values (10msec/frame) for current hypothesis
    #
    # @return [Array] Array of words with start/end frame values (10msec/frame)
    def words
      mp_path_score = FFI::MemoryPointer.new(:int32, 1)
      start_frame   = FFI::MemoryPointer.new(:int32, 1)
      end_frame     = FFI::MemoryPointer.new(:int32, 1)

      seg_iter = ps_api.ps_seg_iter(ps_decoder, mp_path_score)
      words    = []

      until seg_iter.null? do
        ps_api.ps_seg_frames(seg_iter, start_frame, end_frame)
        words << Pocketsphinx::Decoder::Word.new(
          ps_api.ps_seg_word(seg_iter),
          start_frame.get_int32(0),
          end_frame.get_int32(0)
        )
        seg_iter = ps_api.ps_seg_next(seg_iter)
      end

      words
    end

    # Adds new search using JSGF model.
    #
    # Convenience method to parse JSGF model from string and create a search.
    #
    # @param [String] jsgf_string The JSGF grammar
    # @param [String] name The search name
    def set_jsgf_string(jsgf_string, name = 'default')
      api_call :ps_set_jsgf_string, ps_decoder, name, jsgf_string
    end

    # Returns name of curent search in decoder
    def get_search
      ps_api.ps_get_search(ps_decoder)
    end

    # Actives search with the provided name.
    #
    # Activates search with the provided name. The search must be added before
    # using either ps_set_fsg(), ps_set_lm() or ps_set_kws().
    def set_search(name = 'default')
      api_call :ps_set_search, ps_decoder, name
    end

    # Unsets the search and releases related resources.
    #
    # Unsets the search previously added with
    # using either ps_set_fsg(), ps_set_lm() or ps_set_kws().
    def unset_search(name = 'default')
      api_call :ps_unset_search, ps_decoder, name
    end

    def ps_api
      @ps_api || API::Pocketsphinx
    end

    def ps_decoder
      init_decoder if @ps_decoder.nil?
      @ps_decoder
    end

    private

    def init_decoder
      @ps_decoder = ps_api.ps_init(configuration.ps_config)
      post_init_decoder
    end

    def reinit_decoder
      ps_api.ps_reinit(ps_decoder, configuration.ps_config).tap do |result|
        raise API::Error, "Decoder#reconfigure failed with error code #{result}" if result < 0
        post_init_decoder
      end
    end

    def post_init_decoder
      if configuration.respond_to?(:post_init_decoder)
        configuration.post_init_decoder(self)
      end
    end
  end
end
