module Pocketsphinx
  module Grammar
    class JsgfBuilder
      def initialize
        @sentences = []
      end

      def sentence(sentence)
        @sentences << sentence
      end

      def jsgf
        header + sentences_rule
      end

      private

      def header
        "#JSGF V1.0;\n\ngrammar default;\n\n"
      end

      def sentences_rule
        "public <sentence> = #{@sentences.map(&:downcase).join(' | ')};"
      end
    end
  end
end
