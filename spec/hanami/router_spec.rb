RSpec.describe Hanami::Router do
  describe '.define' do
    it 'returns block as it is' do
      routes = expect { get '/', to: ->(env) {[200, {}, ['OK']]} }
      Hanami::Router.define(&routes).to eq(routes)
    end
  end
end
