# frozen_string_literal: true

class RecognitionTestCase
  include ::RSpec::Matchers
  HEADER_ENV     = "_env"
  ROUTER_PARAMS  = "router.params"
  REQUEST_METHOD = "REQUEST_METHOD"

  def self.endpoint(body)
    ->(env) { [200, {HEADER_ENV => env}, [body]] }
  end

  def initialize(router)
    @router = router
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def run!(tests)
    tests.each do |(name, request, params, verb)|
      env                   = Rack::MockRequest.env_for(request)
      env[REQUEST_METHOD]   = verb unless verb.nil?

      status, headers, body = *@router.call(env)

      case status
      when 200
        expect(headers[HEADER_ENV][ROUTER_PARAMS]).to eq(params || {})
        expect(body).to eq(Array(name.to_s))
      when 404
        expect(name).to be_nil
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
