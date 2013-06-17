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
          controller, action = result.split(/#/).map {|token| titleize(token) }
          controller + 'Controller::' + action
        else
          titleize(result)
        end

        return @namespace.const_get(result).new
      end

      default
    end

    def find(options, &endpoint)
      options[:to]
    end

    private
    def default
      ->(env) { [404, {'X-Cascade' => 'pass'}, 'Not Found'] }
    end

    # FIXME extract
    def titleize(string)
      string.split('_').map {|token| token.slice(0).upcase + token.slice(1..-1) }.join
    end
  end
end
