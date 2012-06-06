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
      if model.respond_to? :find_by_remote_id
        process_message(model, message)
      end
    end
  end

  def process_message(model, message)
    results = {}
    if message['versions'].present?
      handle_versions(model, message['versions'], results)
    end
    if message['updates'].present?
      handle_updates(model, message['updates'], results)
    end
    if message['creates'].present?
      results['conflict'], results['ack'] =
        handle_creates(model, message['creates'])
    end
    publish_results(message, results)
  end

  def handle_versions(model, versions, results)
    versions.each do |version|
      check_version(model, version, results)
    end
  end

  def check_version(model, version, results)
    results['update'] ||= {}
    results['resolve'] ||= []
    object = model.find_by_remote_id(version['id'])
    if object
      # Detect id conflict caused by haphazardly generating
      # random id on client
      if version['is_new']
        results['resolve'] << version['id']
        false
      # Compare the client version to the server version
      # to see if the server supersedes the client
      elsif object.remote_version.supersedes? version['version']
        results['update'][object.remote_id] = json_for(object)
        false
      else
        [true, object]
      end
    else
      true
    end
  end

  def handle_updates(model, updates, results)
    results['ack'] ||= {}
    updates.each do |update|
      check_version(model, update, results)
    end
  end

  def handle_creates(model, creates)
    conflicts = []
    acks = {}
    creates.each do |create|
      if model.where(:remote_id => create['id']).blank?
        object = model.create(:remote_id => create['id'])
        object.update_attributes(create['attributes'])
        object.update_attribute(:remote_version, create['version'])
        acks[create['id']] = create['version']
      else
        conflicts << create['id']
      end
    end
    [conflicts, acks]
  end

  def json_for(object)
    object.attributes.reject do |key, value|
      ['id', 'remote_id'].include? key.to_s
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