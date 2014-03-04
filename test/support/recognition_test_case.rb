class RecognitionTestCase
  HEADER_ENV     = '_env'.freeze
  ROUTER_PARAMS  = 'router.params'.freeze
  REQUEST_METHOD = 'REQUEST_METHOD'.freeze

  def self.endpoint(body)
    ->(env) {[200, {HEADER_ENV => env}, [body]]}
  end

  def initialize(router)
    @router = router
  end

  def run!(tests)
    tests.each do |(name, request, params, verb)|
      env                   = Rack::MockRequest.env_for(request)
      env[REQUEST_METHOD]   = verb unless verb.nil?

      status, headers, body = *@router.call(env)

      case status
      when 200
        headers[HEADER_ENV][ROUTER_PARAMS].must_equal params || {}
        body.must_equal                               Array(name.to_s)
      when 404
        name.must_be_nil
      end
    end
  end
end
