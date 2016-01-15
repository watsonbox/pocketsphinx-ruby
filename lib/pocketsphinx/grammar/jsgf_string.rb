require_relative 'jsgf'
module Pocketsphinx
  module Grammar
    class JsgfString < Jsgf
      # @param [String] raw
      def initialize(jsgf_string)
        super(jsgf_string)
      end
    end
  end
end
