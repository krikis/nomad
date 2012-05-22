require File.expand_path('../app',    __FILE__)
require File.expand_path('../client', __FILE__)

class SyncServer
  include Faye::Logging

  def initialize(port = nil, ssl = nil)
    @port = port || 9292
    @secure = ssl == 'ssl'
    @logfile = File.expand_path('../log/faye.log', __FILE__)
    # Faye::Logging.log_level = :info
    Faye.logger = lambda {|m| File.open(@logfile, 'a'){|f| f.puts m}}
    EM.error_handler do |e|
      error("Error during event loop: " +
            "#{e.class} (#{e.message}):\n    " +
            "#{clean_backtrace(e).join("\n    ")}")
    end
  end

  def clean_backtrace(exception)
    defined? Rails and Rails.respond_to?(:backtrace_cleaner) ?
      Rails.backtrace_cleaner.send(:filter, exception.backtrace) :
      exception.backtrace
  end

  def run
    Faye::WebSocket.load_adapter('thin')
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

