require 'lotus/utils/class_attribute'
require 'lotus/routing/resource/options'
require 'lotus/routing/resource/action'

module Lotus
  module Routing
    class Resource
      include Utils::ClassAttribute

      class_attribute :actions
      self.actions = [:new, :create, :show, :edit, :update, :destroy]

      class_attribute :action
      self.action = Resource::Action

      class_attribute :member
      self.member = Resource::MemberAction

      class_attribute :collection
      self.collection = Resource::CollectionAction

      def initialize(router, name, options = {}, &blk)
        @router  = router
        @name    = name
        @options = Options.new(self.class.actions, options.merge(name: @name))
        generate(&blk)
      end

      private
      def generate(&blk)
        @options.actions.each do |action|
          self.class.action.generate(@router, action, @options)
        end

        instance_eval(&blk) if block_given?
      end

      def member(&blk)
        self.class.member.new(@router, @options.merge(prefix: @name), &blk)
      end

      def collection(&blk)
        self.class.collection.new(@router, @options.merge(prefix: @name), &blk)
      end
    end
  end
end
