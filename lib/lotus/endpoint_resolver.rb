require 'lotus/utils/string'
require 'lotus/routing/endpoint'

module Lotus
  class EndpointResolver
    def initialize(namespace = Object)
      @namespace = namespace
    end

    def resolve(options, &endpoint)
      result = endpoint || find(options)
      return Routing::Endpoint.new(result) if result.respond_to?(:call)

      if result.respond_to?(:match)
        result = if result.match(/#/)
          controller, action = result.split(/#/).map {|token| Utils::String.titleize(token) }
          controller + 'Controller::' + action
        else
          Utils::String.titleize(result)
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

    private
    def default
      Routing::Endpoint.new(
        ->(env) { [404, {'X-Cascade' => 'pass'}, 'Not Found'] }
      )
    end

    def constantize(string)
      begin
        Routing::ClassEndpoint.new(@namespace.const_get(string))
      rescue NameError
        Routing::LazyEndpoint.new(string, @namespace)
      end
    end
  end
end
