# frozen_string_literal: true

require "hanami/routing/resource"
require "hanami/routing/resources/action"

module Hanami
  module Routing
    # Set of RESTful resources routes
    # Implementation of Hanami::Router#resources
    #
    # @since 0.1.0
    #
    # @api private
    #
    # @see Hanami::Router#resources
    class Resources < Resource
      # Set of default routes
      #
      # @api private
      # @since 0.1.0
      self.actions = %i[index new create show edit update destroy]

      # Action class
      #
      # @api private
      # @since 0.1.0
      self.action = Resources::Action

      # Member action class
      #
      # @api private
      # @since 0.1.0
      self.member = Resources::MemberAction

      # Collection action class
      #
      # @api private
      # @since 0.1.0
      self.collection = Resources::CollectionAction

      # Return wildcard param between separators
      #
      # @api private
      # @since 0.4.0
      def wildcard_param(route_param = nil)
        "/:#{Hanami::Utils::String.singularize(route_param)}_id/"
      end
    end
  end
end
