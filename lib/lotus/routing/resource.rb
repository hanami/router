require 'lotus/utils/class_attribute'
require 'lotus/routing/resource/options'
require 'lotus/routing/resource/action'

module Lotus
  module Routing
    # Set of RESTful resource routes
    # Implementation of Lotus::Router#resource
    #
    # @since 0.1.0
    #
    # @api private
    #
    # @see Lotus::Router#resource
    class Resource
      include Utils::ClassAttribute

      # Set of default routes
      #
      # @api private
      # @since 0.1.0
      class_attribute :actions
      self.actions = [:new, :create, :show, :edit, :update, :destroy]

      # Action class
      #
      # @api private
      # @since 0.1.0
      class_attribute :action
      self.action = Resource::Action

      # Member action class
      #
      # @api private
      # @since 0.1.0
      class_attribute :member
      self.member = Resource::MemberAction

      # Collection action class
      #
      # @api private
      # @since 0.1.0
      class_attribute :collection
      self.collection = Resource::CollectionAction

      # @api private
      # @since 0.1.0
      def initialize(router, name, options = {}, &blk)
        @router  = router
        @name    = name
        @options = Options.new(self.class.actions, options.merge(name: @name))
        generate(&blk)
      end

      private
      def generate(&blk)
        instance_eval(&blk) if block_given?

        @options.actions.each do |action|
          self.class.action.generate(@router, action, @options)
        end
      end

      def member(&blk)
        self.class.member.new(@router, @options, &blk)
      end

      def collection(&blk)
        self.class.collection.new(@router, @options, &blk)
      end
    end
  end
end
