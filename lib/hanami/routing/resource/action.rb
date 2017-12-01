# frozen_string_literal: true

require "hanami/utils/string"
require "hanami/utils/path_prefix"
require "hanami/utils/class_attribute"
require "hanami/routing/resource/nested"

module Hanami
  module Routing
    class Resource
      # Action for RESTful resource
      #
      # @since 0.1.0
      #
      # @api private
      #
      # @see Hanami::Router#resource
      class Action
        include Utils::ClassAttribute

        # Nested routes separator
        #
        # @api private
        # @since 0.4.0
        NESTED_ROUTES_SEPARATOR = "/"

        # Ruby namespace where lookup for default subclasses.
        #
        # @api private
        # @since 0.1.0
        class_attribute :namespace
        self.namespace = Resource

        # Accepted HTTP verb
        #
        # @api private
        # @since 0.1.0
        class_attribute :verb
        self.verb = :get

        # Separator for named routes
        #
        # @api private
        # @since 0.2.0
        class_attribute :named_route_separator
        self.named_route_separator = "_"

        # Generate an action for the given router
        #
        # @param router [Hanami::Router]
        # @param action [Hanami::Routing::Resource::Action]
        # @param options [Hash]
        # @param resource [Hanami::Routing::Resource, Hanami::Routing::Resources]
        #
        # @api private
        #
        # @since 0.1.0
        def self.generate(router, action, options = {}, resource = nil)
          class_for(action).new(router, options, resource)
        end

        # Initialize an action
        #
        # @param router [Hanami::Router]
        # @param options [Hash]
        # @param resource [Hanami::Routing::Resource, Hanami::Routing::Resources]
        # @param blk [Proc]
        #
        # @api private
        #
        # @since 0.1.0
        def initialize(router, options = {}, resource = nil, &blk)
          @router = router
          @options = options
          @resource = resource
          generate(&blk)
        end

        # Generate an action for the given router
        #
        # @param blk [Proc]
        #
        # @api private
        #
        # @since 0.1.0
        def generate(&blk)
          @router.send verb, path, to: endpoint, as: as, namespace: namespace, configuration: configuration
          instance_eval(&blk) if block_given?
        end

        # Resource name
        #
        # @return [String]
        #
        # @api private
        # @since 0.1.0
        #
        # @example
        #   require 'hanami/router'
        #
        #   Hanami::Router.new do
        #     resource 'identity'
        #   end
        #
        #   # 'identity' is the name passed in the @options
        def resource_name
          @resource_name ||= @options[:name].to_s
        end

        # Prefix
        #
        # @api private
        # @since x.x.x
        def prefix
          @prefix ||= Utils::PathPrefix.new(@options[:prefix])
        end

        # Namespace
        #
        # @api private
        # @since x.x.x
        def namespace
          @namespace ||= @options[:namespace]
        end

        # Configuration
        #
        # @api private
        # @since x.x.x
        def configuration
          @configuration ||= @options[:configuration]
        end

        # Load a subclass, according to the given action name
        #
        # @param action [String] the action name
        #
        # @example
        #   Hanami::Routing::Resource::Action.send(:class_for, 'New') # =>
        #     Hanami::Routing::Resource::New
        #
        # @api private
        # @since 0.1.0
        def self.class_for(action)
          Utils::Class.load!(Utils::String.classify(action), namespace)
        end

        private_class_method :class_for

        # Accepted HTTP verb
        #
        # @see Hanami::Routing::Resource::Action.verb
        #
        # @api private
        # @since 0.1.0
        def verb
          self.class.verb
        end

        # The prefixed relative URL
        #
        # @example
        #   require "hanami/router"
        #
        #   Hanami::Router.new do
        #     resources "flowers"
        #
        #     prefix "animals" do
        #       resources "mammals"
        #     end
        #   end
        #
        #   # It will generate paths like "/flowers", "/flowers/:id" ..
        #   # It will generate paths like "/animals/mammals", "/animals/mammals/:id" ..
        #
        # @api private
        # @since 0.1.0
        def path
          rest_path
        end

        # The URL relative path
        #
        # @example
        #   '/flowers'
        #   '/flowers/new'
        #   '/flowers/:id'
        #
        # @api private
        # @since 0.1.0
        def rest_path
          prefix.join(_nested_rest_path || resource_name.to_s)
        end

        # The prefixed name of the action within the whole context of the router.
        #
        # @example
        #   require "hanami/router"
        #
        #   Hanami::Router.new do
        #     resources "flowers"
        #
        #     prefix "animals" do
        #       resources "mammals"
        #     end
        #   end
        #
        #   # It will generate named routes like :flowers, :new_flowers ..
        #   # It will generate named routes like :animals_mammals, :animals_new_mammals ..
        #
        # @api private
        # @since 0.1.0
        def as
          prefix.relative_join(_singularized_as, self.class.named_route_separator).to_sym
        end

        # The name of the RESTful action.
        #
        # @example
        #   'index'
        #   'new'
        #   'create'
        #
        # @api private
        # @since 0.1.0
        def action_name
          Utils::String.transform(self.class.name, :demodulize, :downcase)
        end

        # A string that represents the endpoint to be loaded.
        # It is composed by controller and action name.
        #
        # @see Hanami::Routing::Resource::Action#separator
        #
        # @example
        #   'flowers#index'
        #
        # @api private
        # @since 0.1.0
        def endpoint
          [controller_name, action_name].join separator
        end

        # Separator between controller and action name
        #
        # @see Hanami::Routing::EndpointResolver#separator
        #
        # @example
        #   '#' # default
        #
        # @api private
        # @since 0.1.0
        def separator
          @options[:separator]
        end

        # Resource controller name
        #
        # @example
        #   Hanami::Router.new do
        #     resources 'flowers', controller: 'rocks'
        #   end
        #
        #   # It will mount path 'flowers/new' to Rocks::New instead of Flowers::New
        #   # Same for other action names
        #
        # @api private
        # @since 0.4.0
        def controller_name
          @options[:controller] || resource_name
        end

        private

        # Singularize as (helper route)
        #
        # @api private
        # @since 0.4.0
        def _singularized_as
          name = @options[:as] ? @options[:as].to_s : resource_name
          name.split(NESTED_ROUTES_SEPARATOR).map do |n|
            Hanami::Utils::String.singularize(n)
          end
        end

        # Create nested rest path
        #
        # @api private
        # @since 0.4.0
        def _nested_rest_path
          Nested.new(resource_name, @resource).to_path
        end
      end

      # Collection action
      # It implements #collection within a #resource block.
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class CollectionAction < Action
        # @since 0.1.0
        # @api private
        def generate(&blk)
          instance_eval(&blk) if block_given?
        end

        protected

        # @since 0.1.0
        # @api private
        def method_missing(m, *args) # rubocop:disable Style/MethodMissing
          verb        = m
          action_name = Utils::PathPrefix.new(args.first).relative_join(nil)

          @router.__send__ verb, path(action_name),
                           to: endpoint(action_name), as: as(action_name),
                           namespace: namespace, configuration: configuration
        end

        private

        # @since 0.1.0
        # @api private
        def path(action_name)
          rest_path.join(action_name)
        end

        # @since 0.1.0
        # @api private
        def endpoint(action_name)
          [controller_name, action_name].join separator
        end

        # @since 0.1.0
        # @api private
        def as(action_name)
          [action_name, super()].join(self.class.named_route_separator).to_sym
        end
      end

      # Collection action
      # It implements #member within a #resource block.
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class MemberAction < CollectionAction
      end

      # Implementation of common methods for concrete member actions
      #
      # @api private
      # @since 0.1.0
      module DefaultMemberAction
        private

        # @since 0.1.0
        # @api private
        def path
          rest_path.join(action_name)
        end

        # @since 0.1.0
        # @api private
        def as
          [action_name, super].join(self.class.named_route_separator).to_sym
        end
      end

      # New action
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class New < Action
        include DefaultMemberAction
      end

      # Create action
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class Create < Action
        self.verb = :post
      end

      # Show action
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class Show < Action
      end

      # Edit action
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class Edit < Action
        include DefaultMemberAction
      end

      # Update action
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class Update < Action
        self.verb = :patch
      end

      # Destroy action
      #
      # @api private
      # @since 0.1.0
      # @see Hanami::Router#resource
      class Destroy < Action
        self.verb = :delete
      end
    end
  end
end
