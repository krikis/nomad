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

def on_black
  "\e[40m"
end

def light_blue_on_black
  "#{on_black}\e[1;36m"
end

def green_on_black
  "#{on_black}\e[1;32m"
end

def red_on_black
  "#{on_black}\e[1;31m"
end

def reset
  "\e[0m"
end

def highlight_keyword(string, keyword, color)
  string.gsub! /\"#{keyword}\"=>\"([^"]+)\"/,  "\"#{color}#{keyword}#{reset}\"=>\"\\1\""
  string.gsub! /\"#{keyword}\"=>\[([^\]]+)\]/, "\"#{color}#{keyword}#{reset}\"=>[\\1]"
  string.gsub! /\"#{keyword}\"=>\{([^\}]+)\}/, "\"#{color}#{keyword}#{reset}\"=>{\\1}"
end

def highlight_string_attribute(string, attribute, color, content_color)
  string.gsub! /\"#{attribute}\"=>\"([^"]+)\"/,
               "\"#{color}#{attribute}#{reset}\"=>\"#{content_color}\\1#{reset}\""
end

def highlight_hash_attribute(string, attribute, color, content_color)
  string.gsub! /\"#{attribute}\"=>\{([^\}]+)\}/,
               "\"#{color}#{attribute}#{reset}\"=>#{content_color}{\\1}#{reset}"
end

def highlight_array_attribute(string, attribute, color, content_color)
  string.gsub! /\"#{attribute}\"=>\[([^\]]+)\]/,
               "\"#{color}#{attribute}#{reset}\"=>#{content_color}[\\1]#{reset}"
end

App.bind(:publish) do |client_id, channel, data|
  output = data.inspect
  ['new_versions', 'create', 'creates',
   'versions',     'update', 'updates'].each do |keyword|
    highlight_keyword(output, keyword, light_blue_on_black)
  end
  ['version', 'remote_version'].each do |keyword|
    highlight_hash_attribute(output,
                             keyword,
                             green_on_black,
                             red_on_black)
  end
  ['client_id'].each do |attribute|
    highlight_string_attribute(output,
                               attribute,
                               light_blue_on_black,
                               green_on_black)
  end
  error output
end