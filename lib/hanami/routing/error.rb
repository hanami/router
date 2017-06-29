module Hanami
  module Routing
    # @since 0.5.0
    class Error < ::StandardError
    end

    # Invalid route
    # This is raised when the router fails to recognize a route, because of the
    # given arguments.
    #
    # @since 0.1.0
    class InvalidRouteException < Error
    end
  end
end
