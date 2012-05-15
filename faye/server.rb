require 'rubygems'

port   = ARGV[0] || 9292
secure = ARGV[1] == 'ssl'
shared = File.expand_path('../../shared', __FILE__)

require File.expand_path('../app', __FILE__)
Faye::WebSocket.load_adapter('thin')
# Faye::Logging.log_level = :debug

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
}

