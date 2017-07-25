module Pocketsphinx
  module Grammar
    class Jsgf
      attr_reader :raw

      # A convenience method for creating a new {Jsgf} from a string
      # @param jsgf_string  [String]  the JSGF string to use
      def self.from_string(jsgf_string)
        self.new(nil, jsgf_string)
      end

      # @param path [String]  the path to the file to be loaded
      # @param jsgf [String]  a string to be parsed as a JSGF grammar (set path to nil)
      def initialize(path = nil, jsgf = nil, &block)
        if path.nil? && jsgf.nil? && !block_given?
          raise "Either a path or block is required to create a JSGF grammar"
        end

        if block_given?
          @raw = grammar_from_block(&block)
        elsif jsgf
          @raw = jsgf
          check_grammar
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
        raise 'Invalid JSGF grammar' unless raw.lines.first && raw.lines.first.strip == "#JSGF V1.0;"
      end
    end
  end
end
