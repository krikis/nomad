class ServerSideClient
  include Faye::Logging
  include Faye::Sync
  include Faye::Versioning

  def initialize(client)
    @client = client
  end

  # subscribe server-side client to all server synchronization channels
  def subscribe
    @client.subscribe('/server/*') do |message|
      # hook in the message processing callback
      on_server_message(message)
    end
  end

  # process synchronization message from browser
  def on_server_message(message)
    # reset db for test purposes
    if message['reset_db']
      error 'Resetting sqlite3 test db...'
      `cp db/test.sqlite3.clean db/test.sqlite3`
      publish_results(message, 'unicast'=> {'_dbReset' => true, 'meta' => {}})
    elsif model = message['model_name'].safe_constantize
      if model.respond_to? :find_by_remote_id
        # collect updates since last synchronization phase
        results = add_missed_updates(model, message)
        # process the synchronization message
        process_message(model, message, results)
        # publish collected updates and synchronization results
        publish_results(message, results)
      end
    end
  end

  # publish the results of a synchronization session
  def publish_results(message, results)
    # publish successfully saved changes to all nodes in the network
    multicast_channel = "/sync/#{message['model_name']}"
    if results['multicast'].andand['create'].present? or
       results['multicast'].andand['update'].present?
      @client.publish(multicast_channel, results['multicast'])
    end
    # publish detected conflicts or missed updates to the current client only
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