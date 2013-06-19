module Lotus
  module Utils
    class PathPrefix < ::String
      def initialize(string = nil, separator = '/')
        @separator = separator
        super(string.to_s)
      end

      def join(string)
        absolutize relative_join(string)
      end

      def relative_join(string, separator = @separator)
        separator = separator || @separator
        relativize [self, string].join(separator), separator
      end

      private
      attr_reader :separator

      def absolutize(string)
        string.tap do |s|
          s.insert(0, separator) unless absolute?(s)
        end
      end

      def absolute?(string)
        string.start_with?(separator)
      end

      def relativize(string, separator = @separator)
        string.gsub(%r{(?<!:)#{ separator * 2 }}, separator).gsub(%r{\A#{ separator }}, '')
      end
    end
  end
end
