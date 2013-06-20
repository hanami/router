require 'lotus/routing/resources/options'
require 'lotus/routing/resources/action'

module Lotus
  module Routing
    class Resources
      def initialize(router, name, options = {}, &blk)
        @router  = router
        @name    = name
        @options = Options.new(options.merge(name: @name))
        generate(&blk)
      end

      private
      def generate(&blk)
        @options.actions.each do |action|
          Action.generate(@router, action, @options)
        end

        instance_eval(&blk) if block_given?
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
