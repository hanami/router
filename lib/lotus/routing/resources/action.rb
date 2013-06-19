require 'lotus/utils/string'
require 'lotus/utils/path_prefix'

module Lotus
  module Routing
    class Resources
      class Action
        def self.generate(router, action, options)
          class_for(action).new(router, options).generate
        end

        def initialize(router, options)
          @router, @options = router, options
        end

        def generate
          @router.send verb, path, to: endpoint, as: as
        end

        def name
          @options[:name]
        end

        def prefix
          @prefix ||= Utils::PathPrefix.new @options[:prefix]
        end

        private
        def self.class_for(action)
          Resources.const_get Utils::String.titleize(action)
        end

        def path
          prefix.join(rest_path)
        end

        def as
          prefix.relative_join(named_route, '_').to_sym
        end
      end

      class Index < Action
        private
        def verb
          :get
        end

        def endpoint
          "#{ name }#index"
        end

        def rest_path
          "/#{ name }"
        end

        def named_route
          name
        end
      end

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

      class Show < Action
        private
        def verb
          :get
        end

        def endpoint
          "#{ name }#show"
        end

        def rest_path
          "/#{ name }/:id"
        end

        def named_route
          name
        end
      end

      class Edit < Action
        private
        def verb
          :get
        end

        def endpoint
          "#{ name }#edit"
        end

        def rest_path
          "/#{ name }/:id/edit"
        end

        def named_route
          "edit_#{ name }"
        end
      end

      class Update < Action
        private
        def verb
          :patch
        end

        def endpoint
          "#{ name }#update"
        end

        def rest_path
          "/#{ name }/:id"
        end

        def named_route
          name
        end
      end

      class Destroy < Action
        private
        def verb
          :delete
        end

        def endpoint
          "#{ name }#destroy"
        end

        def rest_path
          "/#{ name }/:id"
        end

        def named_route
          name
        end
      end
    end
  end
end
