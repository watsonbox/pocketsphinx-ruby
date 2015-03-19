module Pocketsphinx
  module API
    module Sphinxbase
      module Cmn
        extend FFI::Library

        enum :cmn_type, [:none, 0, :current, :prior]
        enum :agc_type, [:none, 0, :max, :emax, :noise]

        class CmnData < FFI::Struct
          layout :cmn_mean, :pointer,
            :cmn_var, :pointer,
            :sum, :pointer,
            :nframe, :int32,
            :veclen, :int32
        end

        class Feature < FFI::Struct
          layout :refcount, :int,
            :name,  :string,
            :cepsize, :int32,
            :n_stream, :int32,
            :stream_len, :pointer,
            :window_size, :int32,
            :n_sv, :int32,
            :sv_len, :pointer,
            :subvecs, :pointer,
            :mfcc_t, :pointer,
            :sv_dim, :int32,
            :cmn, :cmn_type,
            :varnorm, :int32,
            :agc, :agc_type,
            :compute_feat, :pointer,
            :cmn_struct, CmnData.ptr,
            :agc_struct, :pointer
        end
      end
    end
  end
end
