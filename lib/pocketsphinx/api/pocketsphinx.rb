module Pocketsphinx
  module API
    module Pocketsphinx
      extend FFI::Library
      ffi_lib "libpocketsphinx"

      attach_function :ps_init, [:pointer], :pointer
      attach_function :ps_default_search_args, [:pointer], :void
      attach_function :ps_args, [], :pointer
      attach_function :ps_process_raw, [:pointer, :pointer, :size_t, :int, :int], :int
      attach_function :ps_start_utt, [:pointer, :string], :int
      attach_function :ps_end_utt, [:pointer], :int
      attach_function :ps_get_in_speech, [:pointer], :uint8
      attach_function :ps_get_hyp, [:pointer, :pointer, :pointer], :string
    end
  end
end
