require 'lotus/utils/string'
require 'lotus/utils/path_prefix'
require 'lotus/routing/resource'

module Lotus
  module Routing
    class Resources < Resource
      # Action for RESTful resources
      #
      # @since 0.1.0
      #
      # @api private
      #
      # @see Lotus::Router#resources
      class Action < Resource::Action
        # Ruby namespace where lookup for default subclasses.
        #
        # @api private
        # @since 0.1.0
        self.namespace = Resources

        # Id route variable
        #
        # @since 0.2.0
        # @api private
        class_attribute :identifier
        self.identifier = ':id'.freeze
      end

      # Pluralize concrete actions
      #
      # @api private
      # @since 0.4.0
      module PluralizedAction
        private
        # The name of the RESTful action.
        #
        # @api private
        # @since 0.4.0
        def as
          Lotus::Utils::String.new(super).pluralize
        end
      end

      # Collection action
      # It implements #collection within a #resources block.
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class CollectionAction < Resource::CollectionAction
        def as(action_name)
          Lotus::Utils::String.new(super(action_name)).pluralize
        end
      end

      # Member action
      # It implements #member within a #resources block.
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class MemberAction < Resource::MemberAction
        private
        def path(action_name)
          rest_path.join(Action.identifier, action_name)
        end
      end

      # Implementation of common methods for concrete member actions
      #
      # @api private
      # @since 0.1.0
      module DefaultMemberAction
        private
        def path
          rest_path.join(Action.identifier)
        end
      end

      # Index action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class Index < Action
        include PluralizedAction
        self.verb = :get
      end

      # New action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class New < Resource::New
      end

      # Create action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class Create < Resource::Create
        include PluralizedAction
      end

      # Show action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class Show < Resource::Show
        include DefaultMemberAction
      end

      # Edit action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class Edit < Resource::Edit
        include DefaultMemberAction

        private
        def path
          super.join(action_name)
        end
      end

      # Update action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class Update < Resource::Update
        include DefaultMemberAction
      end

      # Destroy action
      #
      # @api private
      # @since 0.1.0
      # @see Lotus::Router#resources
      class Destroy < Resource::Destroy
        include DefaultMemberAction
      end
    end
  end
end
