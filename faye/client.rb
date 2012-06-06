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
      handle_versions(model, message['versions'], message['client_id'], results)
    end
    if message['updates'].present?
      handle_updates(model, message['updates'], message['client_id'], results)
    end
    publish_results(message, results)
  end

  def handle_versions(model, versions, client_id, results)
    versions.each do |version|
      check_version(model, version, client_id, results)
    end
  end

  def check_version(model, version, client_id, results)
    results['update'] ||= {}
    results['resolve'] ||= []
    object = model.find_by_remote_id(version['id'])
    if object
      # Detect id conflict caused by haphazardly generating
      # random id on client
      if version['is_new']
        results['resolve'] << version['id']
        false
      elsif object.remote_version.obsoletes? version['version'], client_id
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

  def handle_updates(model, updates, client_id, results)
    updates.each do |update|
      success, object = check_version(model, update, client_id, results)
      if success
        process_update(model, object, update, results)
      end
    end
  end

  def process_update(model, object, update, results)
    results['ack'] ||= {}
    object ||= model.create :remote_id => update['id']
    object.update_attributes(update['attributes'])
    object.update_attribute(:remote_version, update['version'])
    results['ack'][update['id']] = update['version']
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