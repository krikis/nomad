class ServerSideClient

  def initialize(client)
    @client = client
  end

  def subscribe
    @client.subscribe('/server/*') do |message|
      on_server_message(message)
    end
  end

  def on_server_message(message)
    @client.publish("/sync/#{message["collection"]}", {'test' => 'message'})
  end

  def publish
    EM.add_periodic_timer(30) {
      @client.publish('/sync/Posts', 'hello' => 'world')
    }
  end
end