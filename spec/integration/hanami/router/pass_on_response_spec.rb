RSpec.describe 'Pass on response' do
  before do
    @routes = Hanami::Router.new { get '/', to: ->(_env) { Rack::Response.new } }
    @app    = Rack::MockRequest.new(@routes)
  end

  # See https://github.com/hanami/router/pull/197
  xit 'is successful' do
    response = @app.get('/', lint: true)
    expect(response.status).to eq(200)
  end
end
