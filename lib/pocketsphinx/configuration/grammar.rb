require 'jsgf'

module Pocketsphinx
  module Configuration
    class Grammar < Default
      attr_accessor :grammar

      # @param path [String,JSGF::Grammar]  the JSGF file to load, or a {JSGF::Grammar}
      def initialize(*args, &block)#(grammar_path = nil)
        super()

        raise "Either a path or block is required to create a JSGF grammar" if args.empty? && !block_given?

        if block_given?
          @grammar = Pocketsphinx::Grammar::Jsgf.new(*args, &block)
        else
          @grammar = args.first.is_a?(JSGF::Grammar) ? args.first : JSGF.read(*args) rescue raise('Invalid JSGF grammar')
        end
      end

      # Since JSGF strings are not supported in Pocketsphinx configuration (only files),
      # we use the post_init_decoder hook to configure the JSGF
      def post_init_decoder(decoder)
        decoder.unset_search
        decoder.set_jsgf_string(grammar.to_s)
        decoder.set_search
      end
    end
  end
end
