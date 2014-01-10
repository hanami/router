module Lotus
  module Routing
    class Resource
      # Options for RESTFul resource(s)
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Router#resource
      # @see Lotus::Router#resources
      class Options < Hash
        # @api private
        # @since 0.1.0
        attr_reader :actions

        # Initialize the options for:
        #   * Lotus::Router#resource
        #   * Lotus::Router#resources
        #
        # @param actions [Array<Symbol>] the name of the actions
        # @param options [Hash]
        # @option options [Hash] :only white list of the default actions
        # @option options [Hash] :except black list of the default actions
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::Routing::Resource
        # @see Lotus::Routing::Resources
        #
        # @example
        #   require 'lotus/router'
        #
        #   Lotus::Router.new do
        #     resources 'articles', only:   [:index]
        #     resource  'profile',  except: [:new, :create, :destroy]
        #   end
        def initialize(actions, options = {})
          only     = Array(options.delete(:only) || actions)
          except   = Array(options.delete(:except))
          @actions = ( actions & only ) - except

          merge! options
        end
      end
    end
  end
end
