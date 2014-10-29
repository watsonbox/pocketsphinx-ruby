module Pocketsphinx
  module Configuration
    class Grammar < Default
      attr_accessor :grammar

      def initialize(*args, &block)#(grammar_path = nil)
        super()

        @grammar = Pocketsphinx::Grammar::Jsgf.new(*args, &block)
      end

      # Since JSGF strings are not supported in Pocketsphinx configuration (only files),
      # we use the post_init_decoder hook to configure the JSGF
      def post_init_decoder(decoder)
        decoder.unset_search
        decoder.set_jsgf_string(grammar.raw)
        decoder.set_search
      end
    end
  end
end
