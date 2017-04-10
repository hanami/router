RSpec.describe Hanami::Router::VERSION do
  it 'exposes version' do
    expect(Hanami::Router::VERSION).to eq('1.0.0')
  end
end
