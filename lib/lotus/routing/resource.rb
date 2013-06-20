require 'lotus/routing/resource/options'
require 'lotus/routing/resource/action'

module Lotus
  module Routing
    class Resource
      @actions = [:new, :create, :show, :edit, :update, :destroy]

      def initialize(router, name, options = {}, &blk)
        @router  = router
        @name    = name
        @options = Options.new(self.class.actions, options.merge(name: @name))
        generate(&blk)
      end

      private
      def generate(&blk)
        @options.actions.each do |action|
          Action.generate(@router, action, @options)
        end

        instance_eval(&blk) if block_given?
      end

      def self.actions
        @actions
      end

      def member(&blk)
        MemberAction.new(@router, @options.merge(prefix: @name), &blk)
      end

      def collection(&blk)
        CollectionAction.new(@router, @options.merge(prefix: @name), &blk)
      end
    end
  end
end
