module Pocketsphinx
  module API
    module SphinxAD
      extend FFI::Library
      ffi_lib "libsphinxad"

      attach_function :ad_open_dev, [:string, :int], :pointer
      attach_function :ad_start_rec, [:pointer], :int32
      attach_function :ad_stop_rec, [:pointer], :int32
      attach_function :ad_read, [:pointer, :pointer, :int], :int
      attach_function :ad_close, [:pointer], :void
    end
  end
end
