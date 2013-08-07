require 'lotus/utils/string'
require 'lotus/routing/endpoint'

module Lotus
  module Routing
    class EndpointResolver
      SUFFIX = 'Controller::'.freeze

      def initialize(options = {})
        @namespace = options[:namespace] || Object
        @suffix    = options[:suffix]    || SUFFIX
      end

      def resolve(options, &endpoint)
        result = endpoint || find(options)
        return Endpoint.new(result) if result.respond_to?(:call)

        if result.respond_to?(:match)
          result = if result.match(/#/)
            controller, action = result.split(/#/).map {|token| Utils::String.new(token).classify }
            controller + @suffix + action
          else
            Utils::String.new(result).classify
          end

          return constantize(result)
        end

        default
      end

      def find(options, &endpoint)
        if prefix = options[:prefix]
          prefix.join(options[:to])
        else
          options[:to]
        end
      end

      protected
      def default
        Endpoint.new(
          ->(env) { [404, {'X-Cascade' => 'pass'}, 'Not Found'] }
        )
      end

      def constantize(string)
        begin
          ClassEndpoint.new(@namespace.const_get(string))
        rescue NameError
          LazyEndpoint.new(string, @namespace)
        end
      end
    end
  end
end
