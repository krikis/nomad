@client.subscribe('/server/*') do |message|
  @client.publish('/sync/posts', :message => 'test')
end

EventMachine.add_periodic_timer(30) {
  @client.publish('/sync/posts', 'hello' => 'world')
}