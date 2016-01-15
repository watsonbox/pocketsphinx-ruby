module Pocketsphinx
  module Grammar
    class JsgfFactory
      public
      def self.from_string(str)
        JsgfString.new(str)
      end

      def self.from_block(&block)
        JsgfSentences.new(&block)
      end

      def self.from_file(path)
        JsgfFile.new(path)
      end
    end
  end
end
