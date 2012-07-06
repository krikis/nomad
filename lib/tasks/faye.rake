app_root = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')
require File.join(app_root, 'faye', 'server')

desc "Start faye server"
task :faye, [:port, :ssl, :kill_running] => :environment do |t, args|
  args.with_defaults(:kill_running => true)
  if args[:kill_running]
    # Kill any old server instances
    while (old_pid = `ps axc|awk "{if (\\$5==\\"test_faye_server\\") print \\$1}"`.strip).present? do
      puts "Stopping old faye server with pid #{old_pid.inspect}..."
      Process.kill(9, old_pid.to_i) rescue nil
    end
  end
  # Set the application name
  $0 = 'test_faye_server'
  # Start new server
  server = SyncServer.new args[:port], args[:ssl]
  server.run
end