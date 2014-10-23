module Pocketsphinx
  module API
    Error = Class.new(StandardError)

    module CallHelpers
      def api_call(method, *args)
        ps_api.send(method, *args).tap do |result|
          if result < 0
            calling_method = caller[2][/`.*'/][1..-2]
            raise Error, "#{self.class.to_s.split('::').last}##{calling_method} failed with error code #{result}"
          end
        end
      end
    end
  end
end
