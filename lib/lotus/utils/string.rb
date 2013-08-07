module Lotus
  module Utils
    class String < ::String
      def initialize(string)
        super(string.to_s)
      end

      def titleize
        split('_').map {|token| token.slice(0).upcase + token.slice(1..-1) }.join
      end
    end
  end
end
