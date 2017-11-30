# frozen_string_literal: true

module RSpec
  module Support
    module Body
      private

      def body_for(value, verb)
        return "" if verb.downcase == "head" # rubocop:disable Performance/Casecmp
        value
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Support::Body
end
