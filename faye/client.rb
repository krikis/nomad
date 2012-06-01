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
    error message.inspect
    results = {}
    results['update'] = handle_changes(model, message['changes'])
    publish_results(message, results)
  end

  def handle_changes(model, changes)
    objects = {}
    changes.each do |change|
      object = model.where(['id is ? and version is not ?',
                           change['id'],
                           change['old_version']]
                          ).first
      objects[object.id] = jsonify(object) if object
    end
    objects
  end

  def handle_creates(model, creates)
    conflicts = acks = []
    creates.each do |create|
      if model.where(:id => create['id']).blank?
        object = model.create(:id => create['id'])
        object.update_attributes(create['attributes'])
        object.update_attribute(:remote_version, create['version'])
        acks << create['id']
      else
        conflicts << create['id']
      end
    end
    [conflicts, acks]
  end

  def jsonify(object)
    object.to_json(:except => [:id, :version])
  end

  def publish_results(message, results)
    channel = "/sync/#{message['model_name']}"
    channel += "/#{message['client_id']}" if message['client_id'].present?
    @client.publish(channel, results)
  end

  def publish
    EM.add_periodic_timer(30) {
      @client.publish('/sync/Post', 'hello' => 'world')
    }
  end
end