port   = @args[:port] || 9292
secure = @args[:ssl] == 'ssl'

require File.expand_path('../app', __FILE__)
Faye::WebSocket.load_adapter('thin')

# Faye::Logging.log_level = :info

EM.run {
  thin = Rack::Handler.get('thin')
  thin.run(App, :Port => port) do |s|

    if secure
      s.ssl = true
      s.ssl_options = {
        :private_key_file => shared + '/server.key',
        :cert_chain_file  => shared + '/server.crt'
      }
    end
  end

  @client = App.get_client

  require File.expand_path('../client', __FILE__)
}

