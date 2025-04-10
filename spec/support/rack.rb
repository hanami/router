# frozen_string_literal: true

module RSpec
  module Support
    module Rack

      # Given a headers hash, respond with headers compatible with current Rack version
      def rack_headers(headers_hash)
        if Hanami::Router.rack_3?
          rack_3_headers = ::Rack::Headers.new

          headers_hash.each do |k, v|
            rack_3_headers[k] = v
          end

          rack_3_headers
        else
          headers_hash
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Support::Rack
end
