require File.expand_path('../app',    __FILE__)
require File.expand_path('../client', __FILE__)

class SyncServer

  def initialize(port = nil, ssl = nil)
    @port = port || 9292
    @secure = ssl == 'ssl'
  end

  def run
    Faye::WebSocket.load_adapter('thin')
    # Faye::Logging.log_level = :info

    EM.run {
      setup_server
      setup_server_side_client
    }
  end

  def setup_server
    thin = Rack::Handler.get('thin')
    thin.run(App, :Port => @port) do |s|
      # TODO:: fix ssl certificate paths
      if @secure
        s.ssl = true
        s.ssl_options = {
          :private_key_file => 'path/to/server.key',
          :cert_chain_file  => 'path/to/server.crt'
        }
      end
    end
  end

  def setup_server_side_client
    server_side_client = ServerSideClient.new(App.get_client)
    server_side_client.subscribe
    server_side_client.publish
  end
end

