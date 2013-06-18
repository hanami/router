require 'lotus/routing/resources/options'
require 'lotus/routing/resources/action'

module Lotus
  module Routing
    class Resources
      def initialize(router, name, options = {})
        @router  = router
        @options = Options.new(options.merge(name: name))
      end

      def generate
        @options.actions.each do |action|
          Action.generate(@router, action, @options)
        end
      end
    end
  end
end
