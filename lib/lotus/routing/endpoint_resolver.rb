require 'lotus/utils/string'
require 'lotus/utils/class'
require 'lotus/routing/endpoint'

module Lotus
  module Routing
    class EndpointResolver
      SUFFIX = '(::Controller::|Controller::)'.freeze
      ACTION_SEPARATOR = /#/.freeze

      def initialize(options = {})
        @endpoint_class = options[:endpoint]  || Endpoint
        @namespace      = options[:namespace] || Object
        @suffix         = options[:suffix]    || SUFFIX
        @separator      = options[:separator] || ACTION_SEPARATOR
      end

      def resolve(options, &endpoint)
        result = endpoint || find(options)
        resolve_callable(result) || resolve_matchable(result) || default
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
        @endpoint_class.new(
          ->(env) { [404, {'X-Cascade' => 'pass'}, 'Not Found'] }
        )
      end

      def constantize(string)
        begin
          ClassEndpoint.new(Utils::Class.load!(string, @namespace))
        rescue NameError
          LazyEndpoint.new(string, @namespace)
        end
      end

      def classify(string)
        Utils::String.new(string).classify
      end

      private
      def resolve_callable(callable)
        if callable.respond_to?(:call)
          @endpoint_class.new(callable)
        end
      end

      def resolve_matchable(matchable)
        if matchable.respond_to?(:match)
          constantize(
            resolve_action(matchable) || classify(matchable)
          )
        end
      end

      def resolve_action(string)
        if string.match(@separator)
          controller, action = string.split(@separator).map {|token| classify(token) }
          controller + @suffix + action
        end
      end
    end
  end
end
