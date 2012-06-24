class ServerSideClient
  include Faye::Logging
  include Faye::Sync

  def initialize(client)
    @client = client
  end

  def subscribe
    @client.subscribe('/server/*') do |message|
      on_server_message(message)
    end
  end

  def on_server_message(message)
    if model = message['model_name'].safe_constantize
      if model.respond_to? :find_by_remote_id
        process_message(model, message)
      end
    end
  end

  def publish_results(message, results)
    multicast_channel = "/sync/#{message['model_name']}"
    if message['creates'].present? or message['updates'].present?
      @client.publish(multicast_channel, results['multicast'])
    end
    if message['client_id'].present?
      unicast_channel = "#{multicast_channel}/#{message['client_id']}"
      if message['new_versions'].present? or message['versions'].present? or
         message['creates'].present? or message['updates'].present?
        @client.publish(unicast_channel, results['unicast'])
      end
    end
  end
end