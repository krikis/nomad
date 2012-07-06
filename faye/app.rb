require 'faye'
include Faye::Logging

App = Faye::RackAdapter.new(#Sinatra::Application,
  :mount   => '/faye',
  :timeout => 25
)

App.bind(:subscribe) do |client_id, channel|
  error "[  SUBSCRIBE] #{client_id} -> #{channel}"
end

App.bind(:unsubscribe) do |client_id, channel|
  # error "[UNSUBSCRIBE] #{client_id} -> #{channel}"
end

App.bind(:disconnect) do |client_id|
  # error "[ DISCONNECT] #{client_id}"
end

def black
  "\e[40m"
end

def azure_on(background)
  "#{background}\e[1;36m"
end

def blue_on(background)
  "#{background}\e[1;34m"
end

def gray_on(background)
  "#{background}\e[1;30m"
end

def green_on(background)
  "#{background}\e[1;32m"
end

def pink_on(background)
  "#{background}\e[1;35m"
end

def red_on(background)
  "#{background}\e[1;31m"
end

def white_on(background)
  "#{background}\e[1;37m"
end

def yellow_on(background)
  "#{background}\e[1;33m"
end

def reset
  "\e[0m"
end

def highlight_key(string, keyword, color)
  string.gsub! /\"#{keyword}\"/,  "\"#{color}#{keyword}#{reset}\""
end

def highlight_key_with_content(string, keyword, color)
  string.gsub! /\"#{keyword}\"=>\"([^"]+)\"/,  "\"#{color}#{keyword}#{reset}\"=>\"\\1\""
  string.gsub! /\"#{keyword}\"=>\[([^\]]+)\]/, "\"#{color}#{keyword}#{reset}\"=>[\\1]"
  string.gsub! /\"#{keyword}\"=>\{([^\}]+)\}/, "\"#{color}#{keyword}#{reset}\"=>{\\1}"
end

def highlight_string_attribute(string, attribute, color, content_color)
  string.gsub! /\"#{attribute}\"=>\"([^"]+)\"/,
               "\"#{color}#{attribute}#{reset}\"=>\"#{content_color}\\1#{reset}\""
end

def highlight_hash_attribute(string, attribute, color, content_color, container_only = false)
  string.gsub! /\"#{attribute}\"=>\{([^\}]+)\}/,
               "\"#{color}#{attribute}#{reset}\"=>#{content_color}{#{reset if container_only}\\1#{content_color if container_only}}#{reset}"
end

def highlight_array_attribute(string, attribute, color, content_color, container_only = false)
  string.gsub! /\"#{attribute}\"=>\[([^\]]+)\]/,
               "\"#{color}#{attribute}#{reset}\"=>#{content_color}[#{reset if container_only}\\1#{content_color if container_only}]#{reset}"
end

App.bind(:publish) do |client_id, channel, data|
  output = data.inspect
  ['new_versions', 'create', 'creates',
   'versions',     'update', 'updates'].each do |keyword|
    highlight_key_with_content(output, keyword, azure_on(black))
  end
  ['version', 'remote_version'].each do |keyword|
    highlight_hash_attribute(output,
                             keyword,
                             green_on(black),
                             red_on(black))
  end
  ['attributes'].each do |keyword|
    highlight_hash_attribute(output,
                             keyword,
                             azure_on(black),
                             red_on(black),
                             true)
  end
  ['client_id', 'id'].each do |attribute|
    highlight_string_attribute(output,
                               attribute,
                               azure_on(black),
                               green_on(black))
  end
  ['unicast'].each do |keyword|
    highlight_key(output, keyword, pink_on(black))
  end
  error output
end