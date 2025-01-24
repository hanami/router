# frozen_string_literal: true

module Hanami
  class Router

    # @since 2.2.0
    # @api private
    def self.modern_rack?
      defined?(Rack::Headers)
    end
  end
end
