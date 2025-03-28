# frozen_string_literal: true

module RSpec
  module Support
    module HTTP
      MOUNTABLE_VERBS = %w[get post delete put patch trace options link unlink].freeze
      VERBS =           MOUNTABLE_VERBS + %w[head].freeze

      def self.mountable_verbs
        MOUNTABLE_VERBS
      end

      def self.verbs
        VERBS
      end

      def self.testable?(mounted, requested)
        (mounted == requested) ||
          (mounted == "get" && requested == "head")
      end

      def self.headers(headers_hash)
        if Hanami::Router.modern_rack?
          headers = Rack::Headers.new

          expected.each do |k, v|
            headers[k] = v
          end

          headers
        else
          expected
        end
      end
    end
  end
end
