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

def light_blue_on_black
  "\e[40m\e[1;36m"
end

def green_on_black
  "\e[40m\e[1;32m"
end

def reset
  "\e[0m"
end

def highlight_keyword(string, keyword)
  string.gsub! /\"#{keyword}\"=>\"([^"]+)\"/,  "\"#{light_blue_on_black}#{keyword}#{reset}\"=>\"\\1\""
  string.gsub! /\"#{keyword}\"=>\[([^\]]+)\]/, "\"#{light_blue_on_black}#{keyword}#{reset}\"=>[\\1]"
  string.gsub! /\"#{keyword}\"=>\{([^\}]+)\}/, "\"#{light_blue_on_black}#{keyword}#{reset}\"=>{\\1}"
end

def highlight_string_attribute(string, attribute)
  string.gsub! /\"#{attribute}\"=>\"([^"]+)\"/, "\"#{light_blue_on_black}#{attribute}#{reset}\"=>\"#{green_on_black}\\1#{reset}\""
end

App.bind(:publish) do |client_id, channel, data|
  output = data.inspect
  [
    'new_versions', 'create', 'creates', 'versions', 'update', 'updates'
  ].each{|keyword| highlight_keyword(output, keyword)}
  [
    'client_id'
  ].each{|attribute| highlight_string_attribute(output, attribute)}
  error output
  # error "[    PUBLISH] #{client_id} #{channel} #{output}"
end