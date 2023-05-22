require "rack/test"

RSpec.xdescribe "SCRIPT_NAME" do
  include Rack::Test::Methods

  before do
    @container = Hanami::Router.new do
      @some_test_router = Hanami::Router.new(prefix: "/admin") do
        get "/foo", to: ->(env) { [200, {}, [::Rack::Request.new(env).url]] }, as: :foo
      end
      mount @some_test_router, at: "/admin"
    end
  end

  def app
    @container
  end

  def response
    last_response
  end

  def request
    last_request
  end

  it "generates proper path" do
    router = @container.instance_variable_get(:@some_test_router)
    expect(router.path(:foo)).to eq("/admin/foo")
  end

  it "generates proper url" do
    router = @container.instance_variable_get(:@some_test_router)
    expect(router.url(:foo)).to eq("http://localhost/admin/foo")
  end

  it "is successfuly parsing a JSON body" do
    script_name = "/admin/foo"
    get script_name

    expect(response.status).to eq(200)
    expect(request.env["SCRIPT_NAME"]).to eq(script_name)
    expect(request.env["SCRIPT_NAME"]).to be_kind_of(String)

    expect(request.env["PATH_INFO"]).to eq("")
    expect(request.env["PATH_INFO"]).to be_kind_of(String)
    expect(response.body).to eq("http://example.org#{script_name}")
  end
end
