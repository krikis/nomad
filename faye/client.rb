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
      reset_db
    elsif model = message['model_name'].safe_constantize
      if model.respond_to? :find_by_remote_id
        results = init_results(message)
        # collect updates since last synchronization phase
        add_missed_objects(model, message, results['unicast'])
        # process the synchronization message
        processed = process_message(model, message, results['unicast'])
        # set lamport clock on processed objects
        version_processed_objects(model, processed, message['model_name'], results['multicast'])
        # add processed objects
        add_processed_objects(model, processed, results['multicast'])
        # publish collected updates and synchronization results
        publish_results(message, results)
      end
    end
  end

  # publish the results of a synchronization session
  def publish_results(message, results)
    # publish successfully saved changes to all nodes in the network
    if results['multicast']['create'].present? or
       results['multicast']['update'].present?
      @client.publish(multicast_channel(message), results['multicast'])
    end
    # publish detected conflicts or missed updates to the current client only
    if message['client_id'].present?
      if message['new_versions'].present? or
         message['versions'].present? or
         results['unicast']['resolve'].present? or
         results['unicast']['update'].present?
        @client.publish(unicast_channel(message), results['unicast'])
      end
    end
  end

  def multicast_channel(message)
    "/sync/#{message['model_name']}"
  end

  def unicast_channel(message)
    "#{multicast_channel(message)}/#{message['client_id']}"
  end

  private

  def reset_db(message)
    error 'Resetting sqlite3 test db...'
    `cp db/test.sqlite3.clean db/test.sqlite3`
    @client.publish(unicast_channel(message),
                    'unicast'=> {'_dbReset' => true, 'meta' => {}})
  end

end