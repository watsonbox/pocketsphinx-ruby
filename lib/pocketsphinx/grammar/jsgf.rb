module Pocketsphinx
  module Grammar
    class Jsgf
      attr_reader :raw

      def initialize(path = nil, &block)
        if path.nil? && !block_given?
          raise "Either a path or block is required to create a JSGF grammar"
        end

        if block_given?
          @raw = grammar_from_block(&block)
        else
          @raw = grammar_from_file(path)
          check_grammar
        end
      end

      def grammar_from_file(path)
        File.read path
      end

      def grammar_from_block(&block)
        builder = JsgfBuilder.new
        builder.instance_eval(&block)
        builder.jsgf
      end

      private

      def check_grammar
        # Simple header check for now
        raise 'Invalid JSGF grammar' unless raw.lines.first.strip == "#JSGF V1.0;"
      end
    end
  end
end
