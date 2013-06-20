require 'http_router/route'

module Lotus
  module Routing
    class Route < HttpRouter::Route
      def generate(resolver, options = {}, &endpoint)
        self.to   = resolver.resolve(options, &endpoint)
        self.name = options[:as].to_sym if options[:as]
        self
      end

      private
      def to=(dest = nil, &blk)
        self.to dest, &blk
      end
    end
  end
end
