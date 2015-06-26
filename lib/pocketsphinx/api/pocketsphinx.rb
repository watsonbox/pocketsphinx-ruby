module Pocketsphinx
  module API
    module Pocketsphinx
      extend FFI::Library
      ffi_lib "libpocketsphinx"

      typedef :pointer, :decoder
      typedef :pointer, :configuration
      typedef :pointer, :logmath

      # Allows expect(API::Pocketsphinx).to receive(:ps_init) in JRuby specs
      def self.ps_init(*args)
        ps_init_private(*args)
      end

      attach_function :ps_init_private, :ps_init, [:configuration], :decoder
      attach_function :ps_reinit, [:decoder, :configuration], :int
      attach_function :ps_default_search_args, [:pointer], :void
      attach_function :ps_args, [], :pointer
      attach_function :ps_decode_raw, [:decoder, :pointer, :long], :int
      attach_function :ps_process_raw, [:decoder, :pointer, :size_t, :int, :int], :int
      attach_function :ps_start_utt, [:decoder], :int
      attach_function :ps_end_utt, [:decoder], :int
      attach_function :ps_get_in_speech, [:decoder], :uint8
      attach_function :ps_get_hyp, [:decoder, :pointer], :string
      attach_function :ps_get_prob, [:decoder], :int32
      attach_function :ps_get_logmath, [:decoder], :logmath
      attach_function :logmath_get_base, [:logmath], FFI::NativeType::FLOAT64
      attach_function :logmath_exp, [:logmath, :int], FFI::NativeType::FLOAT64
      attach_function :ps_set_jsgf_string, [:decoder, :string, :string], :int
      attach_function :ps_unset_search, [:decoder, :string], :int
      attach_function :ps_get_search, [:decoder], :string
      attach_function :ps_set_search, [:decoder, :string], :int

      typedef :pointer, :seg_iter

      attach_function :ps_seg_iter, [:decoder, :pointer], :seg_iter
      attach_function :ps_seg_next, [:seg_iter], :seg_iter
      attach_function :ps_seg_word, [:seg_iter], :string
      attach_function :ps_seg_frames, [:seg_iter, :pointer, :pointer], :void
      attach_function :ps_seg_prob, [:seg_iter, :pointer, :pointer, :pointer], :int32
      attach_function :ps_seg_free, [:seg_iter], :void
    end
  end
end
