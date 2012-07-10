class ServerSideClient
  include Faye::Logging
  include Faye::Sync
  include Faye::Versioning

  def initialize(client)
    @client = client
  end

  def subscribe
    @client.subscribe('/server/*') do |message|
      on_server_message(message)
    end
  end

  def on_server_message(message)
    # reset db for test purposes
    if message['reset_db']
      error 'Resetting sqlite3 test db...'
      `cp db/test.sqlite3.clean db/test.sqlite3`
      publish_results(message, 'unicast'=> {'_dbReset' => true})
    elsif model = message['model_name'].safe_constantize
      if model.respond_to? :find_by_remote_id
        results = add_missed_updates(model, message['last_synced'])
        process_message(model, message, results)
        publish_results(message, results)
      end
    end
  end

  def publish_results(message, results)
    multicast_channel = "/sync/#{message['model_name']}"
    if results['multicast'].andand['create'].present? or
       results['multicast'].andand['update'].present?
      @client.publish(multicast_channel, results['multicast'])
    end
    if message['client_id'].present?
      unicast_channel = "#{multicast_channel}/#{message['client_id']}"
      if message['new_versions'].present? or
         message['versions'].present? or
         results['unicast']['resolve'].present? or
         results['unicast']['update'].present? or
         results['unicast']['_dbReset']
        @client.publish(unicast_channel, results['unicast'])
      end
    end
  end
end