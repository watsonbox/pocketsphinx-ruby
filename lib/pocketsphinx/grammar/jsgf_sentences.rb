require_relative 'jsgf'
module Pocketsphinx
  module Grammar
    class JsgfSentences < Jsgf
      def initialize(&block)
        super(grammar_from_block(&block))
      end

      private
      def grammar_from_block(&block)
        builder = JsgfBuilder.new
        builder.instance_eval(&block)
        builder.jsgf
      end
    end
  end
end

