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
    error message.inspect
    if model = message['model_name'].safe_constantize
      if model.respond_to? :find_by_id
        models = {}
        message['objects'].each do |object|
          object = model.find_by_id object['id']
          models[object.id] = object.to_json(:except => [:id, :version]) if object
        end.compact
        channel = "/sync/#{message['model_name']}"
        channel += "/#{message['client_id']}" if message['client_id'].present?
        @client.publish(channel, {'update' => models})
      end
    end
  end

  def publish
    EM.add_periodic_timer(30) {
      @client.publish('/sync/Post', 'hello' => 'world')
    }
  end
end