require 'lotus/utils/string'

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
          raise NotImplementedError
        end

        def name
          @options[:name]
        end

        private
        def self.class_for(action)
          Resources.const_get Utils::String.titleize(action)
        end
      end

      class Index < Action
        def generate
          @router.get "/#{ name }", to: "#{ name }#index", as: :"#{ name }"
        end
      end

      class New < Action
        def generate
          @router.get "/#{ name }/new", to: "#{ name }#new", as: :"new_#{ name }"
        end
      end

      class Create < Action
        def generate
          @router.post "/#{ name }", to: "#{ name }#create", as: :"#{ name }"
        end
      end

      class Show < Action
        def generate
          @router.get "/#{ name }/:id", to: "#{ name }#show", as: :"#{ name }"
        end
      end

      class Edit < Action
        def generate
          @router.get "/#{ name }/:id/edit", to: "#{ name }#edit", as: :"edit_#{ name }"
        end
      end

      class Update < Action
        def generate
          @router.patch "/#{ name }/:id", to: "#{ name }#update", as: :"#{ name }"
        end
      end

      class Destroy < Action
        def generate
          @router.delete "/#{ name }/:id", to: "#{ name }#destroy", as: :"#{ name }"
        end
      end
    end
  end
end
