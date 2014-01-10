require 'lotus/utils/string'
require 'lotus/utils/path_prefix'
require 'lotus/routing/resource'

module Lotus
  module Routing
    class Resources < Resource
      class Action < Resource::Action
        self.namespace = Resources
      end

      class CollectionAction < Resource::CollectionAction
      end

      class MemberAction < Resource::MemberAction
        private
        def path(path)
          prefix.join("/:id/#{ path }")
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

      class New < Resource::New
      end

      class Create < Resource::Create
      end

      class Show < Resource::Show
        private
        def rest_path
          "/#{ name }/:id"
        end
      end

      class Edit < Resource::Edit
        private
        def rest_path
          "/#{ name }/:id/edit"
        end
      end

      class Update < Resource::Update
        private
        def rest_path
          "/#{ name }/:id"
        end
      end

      class Destroy < Resource::Destroy
        private
        def rest_path
          "/#{ name }/:id"
        end
      end
    end
  end
end
