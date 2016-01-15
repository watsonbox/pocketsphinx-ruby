module Pocketsphinx
  module Configuration
    class Grammar < Default
      attr_accessor :grammar

      def initialize(jsfg_obj) #(grammar_path = nil)
        super()
        raise 'argument has to be of type Grammar::Jsfg' unless jsfg_obj.is_a? Pocketsphinx::Grammar::Jsgf
        @grammar=jsfg_obj
      end

      # Since JSGF strings are not supported in Pocketsphinx configuration (only files),
      # we use the post_init_decoder hook to configure the JSGF
      def post_init_decoder(decoder)
        decoder.set_jsgf_string(grammar.raw)
        decoder.set_search
      end
    end
  end
end
