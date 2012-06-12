require 'faye'
include Faye::Logging

App = Faye::RackAdapter.new(#Sinatra::Application,
  :mount   => '/faye',
  :timeout => 25
)

App.bind(:subscribe) do |client_id, channel|
  # error "[  SUBSCRIBE] #{client_id} -> #{channel}"
end

App.bind(:unsubscribe) do |client_id, channel|
  # error "[UNSUBSCRIBE] #{client_id} -> #{channel}"
end

App.bind(:disconnect) do |client_id|
  # error "[ DISCONNECT] #{client_id}"
end

App.bind(:publish) do |client_id, channel, data|
  error "[    PUBLISH] #{client_id} #{channel} #{data}"
end