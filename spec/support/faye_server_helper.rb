require 'daemons'
# Require the faye server source code
app_root = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')
require File.join(app_root, 'faye', 'server')

# Kill any old server instances
while (old_pid = `ps axc|awk "{if (\\$5==\\"test_faye_server\\") print \\$1}"`.strip).present? do
  puts "Stopping old faye server with pid #{old_pid.inspect}..."
  Process.kill(9, old_pid.to_i) rescue nil
end

# Fire up new SyncServer
puts "Starting new faye server..."
Daemons.call(:app_name => "test_faye_server") do
  SyncServer.new.run
end