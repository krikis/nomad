class ServerSideClient
  include Faye::Logging

  def initialize(client)
    @client = client
  end

  def subscribe
    @client.subscribe('/server/*') do |message|
      on_server_message(message)
    end
  end

  def on_server_message(message)
    if model = message['model'].safe_constantize
      if model.respond_to? :find_by_id
        models = message['object_ids'].map do |object_id|
          object = model.find_by_id object_id
          object.to_json if object
        end.compact
        @client.publish("/sync/#{message['model']}", {'objects' => models})
      end
    end
  end

  def publish
    EM.add_periodic_timer(30) {
      @client.publish('/sync/Post', 'hello' => 'world')
    }
  end
end