require 'spec_helper'

Spork.each_run do
  # This code will be run each time you run your specs.

  # Check whether Faye server is running
  begin
    Timeout.timeout(1) do
      uri = URI.parse(BackboneSync::Rails::Faye.root_address)
      TCPSocket.new(uri.host, uri.port).close
    end
    FAYE = true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
    raise "Could not connect to Faye server"
  end
end