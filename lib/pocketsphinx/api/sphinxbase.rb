module Pocketsphinx
  module API
    module Sphinxbase
      extend FFI::Library
      ffi_lib "libsphinxbase"

      class Argument < FFI::Struct
        layout :name, :string,
          :type, :int,
          :deflt, :string,
          :doc, :string
      end

      # TODO: Document on ruby side?
      attach_function :cmd_ln_parse_r, [:pointer, :pointer, :int32, :pointer, :int], :pointer
      attach_function :cmd_ln_float_r, [:pointer, :string], :double
      attach_function :cmd_ln_set_float_r, [:pointer, :string, :double], :void
      attach_function :cmd_ln_int_r, [:pointer, :string], :int
      attach_function :cmd_ln_set_int_r, [:pointer, :string, :int], :void
      attach_function :cmd_ln_str_r, [:pointer, :string], :string
      attach_function :cmd_ln_set_str_r, [:pointer, :string, :string], :void
      attach_function :err_set_logfile, [:string], :int
      attach_function :err_set_logfp, [:pointer], :void
    end
  end
end
