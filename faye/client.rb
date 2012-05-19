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
    @client.publish('/sync/posts', :message => 'test')
  end

  def publish
    EM.add_periodic_timer(30) {
      @client.publish('/sync/posts', 'hello' => 'world')
    }
  end
end