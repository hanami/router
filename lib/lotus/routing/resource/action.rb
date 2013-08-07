require 'lotus/utils/string'
require 'lotus/utils/path_prefix'

module Lotus
  module Routing
    class Resource
      class Action
        def self.generate(router, action, options)
          class_for(action).new(router, options)
        end

        def initialize(router, options, &blk)
          @router, @options = router, options
          generate(&blk)
        end

        def generate(&blk)
          @router.send verb, path, to: endpoint, as: as
          instance_eval(&blk) if block_given?
        end

        def name
          @options[:name]
        end

        def prefix
          @prefix ||= Utils::PathPrefix.new @options[:prefix]
        end

        private
        def self.class_for(action)
          Resource.const_get Utils::String.new(action).classify
        end

        def path
          prefix.join(rest_path)
        end

        def as
          prefix.relative_join(named_route, '_').to_sym
        end
      end

      class CollectionAction < Action
        def generate(&blk)
          instance_eval(&blk) if block_given?
        end

        protected
        def method_missing(m, *args, &blk)
          verb, path, _ = m, *args
          @router.send verb, path(path), to: endpoint(path), as: as(path)
        end

        private
        def path(path)
          prefix.join(path)
        end

        def endpoint(path)
          "#{ name }##{ path }"
        end

        def as(path)
          Utils::PathPrefix.new(path).relative_join(name, '_').to_sym
        end
      end

      class MemberAction < CollectionAction
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
          "/#{ name }"
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
          "/#{ name }/edit"
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
          "/#{ name }"
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
          "/#{ name }"
        end

        def named_route
          name
        end
      end
    end
  end
end
