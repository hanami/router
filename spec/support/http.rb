# frozen_string_literal: true

module RSpec
  module Support
    module HTTP
      VERBS = %w[get post delete put patch trace options link unlink].freeze

      def self.verbs
        VERBS
      end
    end
  end
end
