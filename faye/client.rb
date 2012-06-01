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
    if model = message['model_name'].safe_constantize
      if model.respond_to? :where
        process_message(model, message)
      end
    end
  end

  def process_message(model, message)
    results = {}
    if message['changes'].present?
      results['update'] = handle_changes(model, message['changes'])
    end
    if message['creates'].present?
      results['conflict'], results['ack'] =
        handle_creates(model, message['creates'])
    end
    publish_results(message, results)
  end

  def handle_changes(model, changes)
    objects = {}
    changes.each do |change|
      object = model.where(['remote_id is ? and remote_version is not ?',
                           change['id'],
                           change['old_version']]
                          ).first
      objects[object.remote_id] = json_for(object) if object
    end
    objects
  end

  def handle_creates(model, creates)
    conflicts = []
    acks = []
    creates.each do |create|
      if model.where(:remote_id => create['id']).blank?
        object = model.create(:remote_id => create['id'])
        object.update_attributes(create['attributes'])
        object.update_attribute(:remote_version, create['version'])
        acks << create['id']
      else
        conflicts << create['id']
      end
    end
    [conflicts, acks]
  end

  def json_for(object)
    object.attributes.reject do |key, value|
      ['id', 'remote_id', 'remote_version'].include? key.to_s
    end
  end

  def publish_results(message, results)
    channel = "/sync/#{message['model_name']}"
    channel += "/#{message['client_id']}" if message['client_id'].present?
    @client.publish(channel, results)
  end

  def publish
    EM.add_periodic_timer(30) {
      @client.publish('/sync/some_channel', 'hello' => 'world')
    }
  end
end