class ServerSideClient

  def initialize(client)
    @client = client
  end

  def subscribe
    @client.subscribe('/server/*') do |message|
      @client.publish('/sync/posts', :message => 'test')
    end
  end

  def publish
    EM.add_periodic_timer(30) {
      @client.publish('/sync/posts', 'hello' => 'world')
    }
  end
end