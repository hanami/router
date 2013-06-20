module Lotus
  module Routing
    class Resource
      class Options < Hash
        attr_reader :actions

        def initialize(actions, options = {})
          only     = Array(options.delete(:only) || actions)
          except   = Array(options.delete(:except))
          @actions = ( actions & only ) - except

          merge! options
        end
      end
    end
  end
end
