module Lotus
  module Utils
    class String
      def self.titleize(string)
        string.to_s.split('_').map {|token| token.slice(0).upcase + token.slice(1..-1) }.join
      end
    end
  end
end
