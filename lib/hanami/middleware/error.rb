# frozen_string_literal: true

module Hanami
  # Hanami Rack middleware
  #
  # @since 1.3.0
  module Middleware
    unless defined?(Error)
      # Base error for Rack middleware
      #
      # @since x.x.x
      class Error < ::StandardError
      end
    end
  end
end
