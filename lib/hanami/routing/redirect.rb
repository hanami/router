# frozen_string_literal: true

# Hanami
#
# @since 0.1.0
module Hanami
  # Hanami routing
  #
  # @since 0.1.0
  # @api private
  module Routing
    # HTTP redirect
    #
    # @since x.x.x
    # @api private
    class Redirect
      # @since x.x.x
      # @api private
      LOCATION = "Location".freeze

      # @since x.x.x
      # @api private
      STATUS_RANGE = (300..399).freeze

      # Instantiate a new redirect
      #
      # @param path [String] a relative or absolute URI
      # @param status [Integer] a redirect status (an integer between `300` and `399`)
      #
      # @return [Hanami::Routing::Redirect] a new instance
      #
      # @raise [ArgumentError] if path is nil, or status code isn't a redirect
      #
      # @since x.x.x
      # @api private
      def initialize(path, status)
        raise ArgumentError.new("Path is nil") if path.nil?
        raise ArgumentError.new("Status code isn't a redirect: #{status.inspect}") unless STATUS_RANGE.include?(status)

        @path   = path
        @status = status
        freeze
      end

      def call(_)
        [@status, { LOCATION => @path }, []]
      end
    end
  end
end
