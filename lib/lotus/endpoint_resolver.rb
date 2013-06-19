require 'lotus/utils/string'

module Lotus
  class EndpointResolver
    def initialize(namespace = Object)
      @namespace = namespace
    end

    def resolve(options, &endpoint)
      result = endpoint || find(options)
      return result if result.respond_to?(:call)

      if result.respond_to?(:match)
        result = if result.match(/#/)
          controller, action = result.split(/#/).map {|token| Utils::String.titleize(token) }
          controller + 'Controller::' + action
        else
          Utils::String.titleize(result)
        end

        return @namespace.const_get(result).new
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
      ->(env) { [404, {'X-Cascade' => 'pass'}, 'Not Found'] }
    end
  end
end
