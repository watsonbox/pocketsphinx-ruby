module Pocketsphinx
  module API
    module Pocketsphinx
      extend FFI::Library
      ffi_lib "libpocketsphinx"

      typedef :pointer, :decoder
      typedef :pointer, :configuration

      attach_function :ps_init, [:configuration], :decoder
      attach_function :ps_reinit, [:decoder, :configuration], :int
      attach_function :ps_default_search_args, [:pointer], :void
      attach_function :ps_args, [], :pointer
      attach_function :ps_decode_raw, [:decoder, :pointer, :string, :long], :int
      attach_function :ps_process_raw, [:decoder, :pointer, :size_t, :int, :int], :int
      attach_function :ps_start_utt, [:decoder, :string], :int
      attach_function :ps_end_utt, [:decoder], :int
      attach_function :ps_get_in_speech, [:decoder], :uint8
      attach_function :ps_get_hyp, [:decoder, :pointer, :pointer], :string
    end
  end
end
