require 'eventmachine'
require 'faye'
require 'json'

Faye::Logging.log_level = :info

EM.run do
  client = Faye::Client.new('http://localhost:9292/faye')
  puts client.state

  client.subscribe('/server/posts') do |message|
    puts message.inspect
  end

  client.publish('/chat/Tester', {user: 'Tester', message: 'Bladibla'})
end

