desc "Start faye server"
task :faye, [:port, :ssl] => :environment do |t, args|
  @args = args
  app_root = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')
  require File.join(app_root, 'faye', 'server')
end