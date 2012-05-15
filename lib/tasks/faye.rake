app_root = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')
require File.join(app_root, 'faye', 'server')

desc "Start faye server"
task :faye, [:port, :ssl] => :environment do |t, args|
  server = SyncServer.new args[:port], args[:ssl]
  server.run
end