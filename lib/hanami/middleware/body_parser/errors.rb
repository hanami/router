module Hanami
  module Middleware
    # @since 1.3.0
    # @api private
    class BodyParser
      # Body parsing error
      # This is raised when parser fails to parse the body
      #
      # @since 1.3.0
      class BodyParsingError < Hanami::Routing::Parsing::BodyParsingError
      end

      # @since 1.3.0
      class UnknownParserError < Hanami::Routing::Parsing::UnknownParserError
      end
    end
  end
end
