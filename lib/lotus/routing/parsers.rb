module Lotus
  module Routing
    class Parsers
      class UnknownParserError < ::StandardError
        def initialize(parser)
          super("Unknown Parser: `#{ parser }'")
        end
      end

      CONTENT_TYPE       = 'CONTENT_TYPE'.freeze
      MEDIA_TYPE_MATCHER = /\s*[;,]\s*/.freeze

      RACK_INPUT    = 'rack.input'.freeze
      ROUTER_PARAMS = 'router.params'.freeze

      # Supported Content-Types
      #
      APPLICATION_JSON = 'application/json'.freeze
      IMPLEMENTATIONS  = {
        json: 'when APPLICATION_JSON then Rack::Utils::OkJson.decode(body)'
      }.freeze

      def initialize(parsers)
        _compile!(parsers)
      end

      def call(env)
        env
      end


      private
      def _compile!(parsers)
        parsers = Array(parsers)
        return if parsers.empty?

        implementations = parsers.map do |parser|
          IMPLEMENTATIONS.fetch(parser.to_sym) do
            raise UnknownParserError.new(parser)
          end
        end

        instance_eval %{
          def call(env)
            body = env[RACK_INPUT].read
            return env if body.length == 0

            env[RACK_INPUT].rewind    # somebody might try to read this stream
            env[ROUTER_PARAMS] ||= {} # prepare params

            body = case media_type(env)
              #{ implementations.join("\n") }
            else
              {}
            end

            env[ROUTER_PARAMS].merge!(body)

            env
          end
        }
      end

      def media_type(env)
        if ct = content_type(env)
          ct.split(MEDIA_TYPE_MATCHER, 2).first.downcase
        end
      end

      def content_type(env)
        content_type = env[CONTENT_TYPE]
        content_type.nil? || content_type.empty? ? nil : content_type
      end
    end
  end
end
