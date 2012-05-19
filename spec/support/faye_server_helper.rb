require 'daemons'
# Require the faye server source code
app_root = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')
require File.join(app_root, 'faye', 'server')

# Extend SyncServer so that it gives access to its server instance in the tests
class SyncServer
  @@server
  @@daemon
  def self.faye_server
    @@server
  end
  def self.faye_server=(server)
    @@server = server
  end
  def self.faye_daemon
    @@daemon
  end
  def self.faye_daemon=(daemon)
    @@daemon = daemon
  end
end

# Instantiate new SyncServer
SyncServer.faye_server = SyncServer.new

# Kill any old server instances
while (old_pid = `ps axc|awk "{if (\\$5==\\"test_faye_server\\") print \\$1}"`.strip).present? do
  puts "Stopping old faye server with pid #{old_pid.inspect}..."
  Process.kill(9, old_pid.to_i) rescue nil
end

# Fire up new SyncServer
puts "Starting new faye server..."
SyncServer.faye_daemon = Daemons.call(:app_name => "test_faye_server") do
  SyncServer.faye_server.run
end