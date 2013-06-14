module Lotus
  class EndpointResolver
    def initialize(namespace = Object)
      @namespace = namespace
    end

    def resolve(options)
      result = options.delete(:to)
      return result if result.respond_to?(:call)

      result = if result.match(/#/)
        controller, action = result.split(/#/).map {|token| titleize(token) }
        controller + 'Controller::' + action
      else
        titleize(result)
      end

      @namespace.const_get(result).new
    end

    # FIXME extract
    def titleize(string)
      string.split('_').map {|token| token.slice(0).upcase + token.slice(1..-1) }.join
    end
  end
end
