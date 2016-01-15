module Pocketsphinx
  module Grammar
    class JsgfFile < Jsgf
      def initialize(path)
        super(File.read path)
      end
    end
  end
end
