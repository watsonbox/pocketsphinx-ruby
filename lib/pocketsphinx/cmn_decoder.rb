module Pocketsphinx
  class CMNDecoder < Decoder
    CMN_TOLERANCE_DEFAULT = 20

    attr_writer :cmn_tolerance

    def cmn_tolerance
      @cmn_tolerance || CMN_TOLERANCE_DEFAULT
    end

    def decode_raw(audio_file, max_samples = 2048)
      repeat_if_cmn_sum_exceeds { super }
    end

    private

    def repeat_if_cmn_sum_exceeds(tolerance = cmn_tolerance)
      before = cmn_values
      result = yield
      after = cmn_values

      cmn_sum(before, after) > tolerance ? yield : result
    end

    def cmn_sum(before, after)
      before.zip(after).inject(0) { |sum, a| sum + (a.last - a.first).abs }
    end
  end
end
