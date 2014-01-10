require 'lotus/utils/string'
require 'lotus/utils/path_prefix'
require 'lotus/utils/class_attribute'

module Lotus
  module Routing
    class Resource
      # Action for RESTful resource
      #
      # @since 0.1.0
      #
      # @api private
      #
      # @see Lotus::Router#resource
      class Action
        include Utils::ClassAttribute

        # Ruby namespace where lookup for default subclasses.
        #
        # @api private
        # @since 0.1.0
        class_attribute :namespace
        self.namespace = Resource

        # Generate an action for the given router
        #
        # @param router [Lotus::Router]
        # @param action [Lotus::Routing::Resource::Action]
        # @param options [Hash]
        #
        # @api private
        #
        # @since 0.1.0
        def self.generate(router, action, options)
          class_for(action).new(router, options)
        end

        # Initialize an action
        #
        # @param router [Lotus::Router]
        # @param options [Hash]
        # @param blk [Proc]
        #
        # @api private
        #
        # @since 0.1.0
        def initialize(router, options, &blk)
          @router, @options = router, options
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
          @router.send verb, path, to: endpoint, as: as
          instance_eval(&blk) if block_given?
        end

        # Action name
        #
        # @api private
        # @since 0.1.0
        #
        # @example
        #   :index
        #   :edit
        #   :create
        def name
          @options[:name]
        end

        # Path prefix
        #
        # @api private
        # @since 0.1.0
        def prefix
          @prefix ||= Utils::PathPrefix.new @options[:prefix]
        end

        private
        def self.class_for(action)
          Utils::Class.load!(Utils::String.new(action).classify, namespace)
        end

        def path
          prefix.join(rest_path)
        end

        def as
          prefix.relative_join(named_route, '_').to_sym
        end
      end

      # Collection action
      # It implements #collection within a #resource block.
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class CollectionAction < Action
        def generate(&blk)
          instance_eval(&blk) if block_given?
        end

        protected
        def method_missing(m, *args, &blk)
          verb, path, _ = m, *args
          @router.send verb, path(path), to: endpoint(path), as: as(path)
        end

        private
        def path(path)
          prefix.join(path)
        end

        def endpoint(path)
          "#{ name }##{ path }"
        end

        def as(path)
          Utils::PathPrefix.new(path).relative_join(name, '_').to_sym
        end
      end

      # Collection action
      # It implements #member within a #resource block.
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class MemberAction < CollectionAction
      end

      # New action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class New < Action
        private
        def verb
          :get
        end

        def endpoint
          "#{ name }#new"
        end

        def rest_path
          "/#{ name }/new"
        end

        def named_route
          "new_#{ name }"
        end
      end

      # Create action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class Create < Action
        private
        def verb
          :post
        end

        def endpoint
          "#{ name }#create"
        end

        def rest_path
          "/#{ name }"
        end

        def named_route
          name
        end
      end

      # Show action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class Show < Action
        private
        def verb
          :get
        end

        def endpoint
          "#{ name }#show"
        end

        def rest_path
          "/#{ name }"
        end

        def named_route
          name
        end
      end

      # Edit action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class Edit < Action
        private
        def verb
          :get
        end

        def endpoint
          "#{ name }#edit"
        end

        def rest_path
          "/#{ name }/edit"
        end

        def named_route
          "edit_#{ name }"
        end
      end

      # Update action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class Update < Action
        private
        def verb
          :patch
        end

        def endpoint
          "#{ name }#update"
        end

        def rest_path
          "/#{ name }"
        end

        def named_route
          name
        end
      end

      # Destroy action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resource
      class Destroy < Action
        private
        def verb
          :delete
        end

        def endpoint
          "#{ name }#destroy"
        end

        def rest_path
          "/#{ name }"
        end

        def named_route
          name
        end
      end
    end
  end
end
