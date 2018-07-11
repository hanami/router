module Hanami
  module Routing
    # @since 0.5.0
    class Error < ::StandardError
    end

    module Parsing
      # Body parsing error
      # This is raised when parser fails to parse the body
      #
      # @since 0.5.0
      class BodyParsingError < Hanami::Routing::Error
      end

      # @since 0.2.0
      class UnknownParserError < Hanami::Routing::Error
        # @since 0.2.0
        # @api private
        def initialize(parser)
          super("Unknown Parser: `#{ parser }'")
        end
      end
    end
  end
end
