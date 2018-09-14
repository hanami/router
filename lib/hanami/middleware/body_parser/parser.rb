require_relative 'errors'

module Hanami
  module Middleware
    class BodyParser
      # @since 1.3.0
      class Parser
        # @since 1.3.0
        def mime_types
          raise NotImplementedError
        end

        # @since 1.3.0
        def parse(_body)
          raise NotImplementedError
        end
      end
    end
  end
end
