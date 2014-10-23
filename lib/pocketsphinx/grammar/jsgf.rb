module Pocketsphinx
  module Grammar
    class Jsgf
      attr_reader :raw

      def initialize(path)
        @raw = File.read path

        check_grammar
      end

      private

      def check_grammar
        # Simple header check for now
        raise 'Invalid JSGF grammar' unless raw.lines.first.strip == "#JSGF V1.0;"
      end
    end
  end
end
