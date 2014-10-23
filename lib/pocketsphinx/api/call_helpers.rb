module Pocketsphinx
  module API
    Error = Class.new(StandardError)

    module CallHelpers
      def api_call(method, *args)
        calling_method = caller[0][/`.*'/][1..-2]
        ps_api.send(method, *args).tap do |result|
          if result < 0
            raise Error, "#{self.class.to_s.split('::').last}##{calling_method} failed with error code #{result}"
          end
        end
      end
    end
  end
end
