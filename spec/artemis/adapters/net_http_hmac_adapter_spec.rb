require 'json'
require 'rack'

RSpec.describe Artemis::Adapters::NetHttpHmacAdapter do
  FakeServer = ->(env) {
    case env['PATH_INFO']
    when '/slow_server'
      sleep 1.1

      [200, {}, ['{}']]
    when '/500'
      [500, {}, ['Server error']]
    else
      body = {
        data: {
          body: JSON.parse(env['rack.input'].read),
          headers: env.select { |key, _val| key.start_with?('HTTP_') }
                      .collect { |key, val| [key.gsub(/^HTTP_/, ''), val.downcase] }
                      .to_h
        },
        errors: [],
        extensions: {}
      }.to_json

      [200, {}, [body]]
    end
  }

  before :all do
    Artemis::Adapters::AbstractAdapter.send(:attr_writer, :uri, :timeout)

    @server_thread = Thread.new do
      Rack::Handler::WEBrick.run(FakeServer, Port: 8000, Logger: WEBrick::Log.new('/dev/null'), AccessLog: [])
    end

    loop do
      begin
        TCPSocket.open('localhost', 8000)
        break
      rescue Errno::ECONNREFUSED => _e
        # Nothing
      end
    end
  end

  after :all do
    Rack::Handler::WEBrick.shutdown
    @server_thread.terminate
  end

  let(:adapter) { described_class.new('http://localhost:8000', service_name: nil, timeout: 0.5, pool_size: 5) }

  describe '#initialize' do
    it 'requires an url' do
      expect do
        described_class.new(nil, service_name: nil, timeout: 2, pool_size: 5)
      end.to raise_error(ArgumentError, "url is required (given `nil')")
    end
  end

  describe '#execute' do
    subject(:post_request) do
      adapter.execute(
        document: GraphQL::Client::IntrospectionDocument,
        operation_name: 'IntrospectionQuery',
        variables: { id: 'graphql-variable' },
        context: {
          api_auth: {
            access_id: 1,
            secret_key: 'cpc+uIj39Bl823sGAzfjx674gXOvsKI/k5knuzd3PIbtJ54X+muycE7eNE7Kex0H+De5coyB0jdvXva8uEtgsg==',
            digest: 'sha256'
          }
        }
      )
    end

    it 'makes an actual HTTP request' do
      response = post_request
      expect(response['data']['body']['query']).to eq(GraphQL::Client::IntrospectionDocument.to_query_string)
      expect(response['data']['body']['variables']).to eq('id' => 'graphql-variable')
      expect(response['data']['body']['operationName']).to eq('IntrospectionQuery')
      expect(response['errors']).to eq([])
      expect(response['extensions']).to eq({})

      expect(response['data']['headers']).to include('CONTENT_MD5', 'DATE', 'AUTHORIZATION')
    end

    it 'calls ApiAuth' do
      expect(::ApiAuth).to receive(:sign!).with(instance_of(Net::HTTP::Post),
        1, 'cpc+uIj39Bl823sGAzfjx674gXOvsKI/k5knuzd3PIbtJ54X+muycE7eNE7Kex0H+De5coyB0jdvXva8uEtgsg==',
        override_http_method: nil, digest: 'sha256').and_call_original
      post_request
    end

    it 'raises an error when it receives a server error' do
      adapter.uri = URI.parse('http://localhost:8000/500')

      expect { post_request }.to raise_error(Artemis::GraphQLServerError, 'Received server error status 500: Server error')
    end

    it 'allows for overriding timeout' do
      adapter.uri = URI.parse('http://localhost:8000/slow_server')

      expect { post_request }.to raise_error(Net::ReadTimeout)
    end
  end
end
