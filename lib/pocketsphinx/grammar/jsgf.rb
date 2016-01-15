module Pocketsphinx
  module Grammar
    class Jsgf
      attr_reader :raw

      def initialize(raw)
          raise "a raw grammar has to be given" if raw.nil? or not raw.respond_to? :lines
          @raw=raw
          check_grammar
      end

      private
      def check_grammar
        # Simple header check for now
        raise 'Invalid JSGF grammar' unless raw.lines.first && raw.lines.first.strip == '#JSGF V1.0;'
      end
    end
  end
end
