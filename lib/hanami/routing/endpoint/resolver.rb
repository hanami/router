# frozen_string_literal: true

require "hanami/utils/class"
require "hanami/utils/string"

module Hanami
  module Routing
    # Routing endpoint
    #
    # @since
    module Endpoint
      # @since 2.0.0
      # @api private
      class Resolver
        # @since 2.0.0
        # @api private
        #
        # FIXME: Shall this be the default of Utils::Class.load! ?
        DEFAULT_NAMESPACE = Object

        # Replacement to load an action from the string name.
        #
        # Please note that the `"/"` value is required by `Hanami::Utils::String#classify`.
        #
        # Given the `"home#index"` string, with the `Web::Controllers` namespace,
        # it will try to load `Web::Controllers::Home::Index` action.
        #
        # @since 2.0.0
        # @api private
        ACTION_SEPARATOR_REPLACEMENT = "/"

        # Find an endpoint for the given name
        #
        # @param name [String,Class,Proc,Object] the endpoint expressed as name
        #   (`String`), as a Rack class application (`Class`), as a Rack
        #   compatible proc (`Proc`), or as any other Rack compatible object
        #   (`Object`)
        # @param namespace [Module] the Ruby module where to lookup the endpoint
        # @param configuration [Hanami::Controller::Configuration] the action
        #   configuration
        #
        # @raise [Hanami::Routing::NotCallableEndpointError] if the found object
        #   doesn't implement Rack protocol (`#call`)
        #
        # @return [Object, Hanami::Routing::LazyEndpoint] a Rack compatible
        #   endpoint
        #
        # @since 2.0.0
        # @api private
        def call(name, namespace, configuration = nil)
          endpoint = case name
                     when String
                       find_string(name, namespace || DEFAULT_NAMESPACE, configuration)
                     when Class
                       name.respond_to?(:call) ? name : name.new
                     else
                       name
                     end

          raise NotCallableEndpointError.new(endpoint) unless endpoint.respond_to?(:call)

          endpoint
        end

        private

        # Find an endpoint from its name
        #
        # @param name [String] the endpoint name
        # @param namespace [Module] the Ruby module where to lookup the endpoint
        # @param configuration [Hanami::Controller::Configuration] the action
        #   configuration
        #
        # @return [Object, Hanami::Routing::LazyEndpoint] a Rack compatible
        #   endpoint
        #
        # @since 2.0.0
        # @api private
        def find_string(name, namespace, configuration)
          n     = Utils::String.classify(name.sub(ACTION_SEPARATOR, ACTION_SEPARATOR_REPLACEMENT))
          klass = Utils::Class.load!(n, namespace)

          if hanami_action?(name, n)
            klass.new(configuration: configuration)
          else
            klass.new
          end
        rescue NameError
          Hanami::Routing::LazyEndpoint.new(n, namespace)
        end

        def hanami_action?(name, endpoint)
          name != endpoint
        end
      end
    end
  end
end
