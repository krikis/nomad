begin
  Timeout.timeout(1) do
    uri = URI.parse(BackboneSync::Rails::Faye.root_address)
    TCPSocket.new(uri.host, uri.port).close
  end
rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
  raise "Could not connect to Faye"
end