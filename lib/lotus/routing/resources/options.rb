module Lotus
  module Routing
    class Resources
      class Options < Hash
        ACTIONS = [:index, :new, :create, :show, :edit, :update, :destroy]

        def initialize(options = {})
          @only   = Array(options.delete(:only) || ACTIONS)
          @except = Array(options.delete(:except))
          merge! options
        end

        def actions
          (ACTIONS & @only) - @except
        end
      end
    end
  end
end
