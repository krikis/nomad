# require 'sinatra'
require 'faye'

# ROOT_DIR = File.expand_path(File.dirname(__FILE__))
# set :root, ROOT_DIR
# set :logging, false
# 
# get '/' do
#   File.read(ROOT_DIR + '/public/index.html')
# end
# 
# get '/post' do
#   env['faye.client'].publish('/chat/*', {
#     :user => 'sinatra',
#     :message => params[:message]
#   })
#   params[:message]
# end

App = Faye::RackAdapter.new(#Sinatra::Application,
  :mount   => '/faye',
  :timeout => 25
)

App.bind(:subscribe) do |client_id, channel|
  puts "[  SUBSCRIBE] #{client_id} -> #{channel}"
end

App.bind(:unsubscribe) do |client_id, channel|
  puts "[UNSUBSCRIBE] #{client_id} -> #{channel}"
end

App.bind(:disconnect) do |client_id|
  puts "[ DISCONNECT] #{client_id}"
end