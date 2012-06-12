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
    if message['new_versions'].present?
      handle_new_versions(model, message['new_versions'], results)
    end
    if message['versions'].present?
      handle_versions(model,
                      message['versions'],
                      message['client_id'],
                      results)
    end
    if message['creates'].present?
      handle_creates(model, message['creates'], results)
    end
    if message['updates'].present?
      handle_updates(model,
                     message['updates'],
                     message['client_id'],
                     results)
    end
    publish_results(message, results)
  end

  def handle_new_versions(model, new_versions, results)
    results['meta']    ||= {}
    results['unicast'] ||= {}
    new_versions.each do |version|
      check_new_version(model, version, results['unicast'])
    end
    results['meta']['preSync'] = true
  end

  def check_new_version(model, new_version, results)
    results['resolve'] ||= []
    object = model.find_by_remote_id(new_version['id'])
    if object
      # File update for id resolution if random generated id is already taken
      results['resolve'] << new_version['id']
      false
    else
      true
    end
  end

  def handle_versions(model, versions, client_id, results)
    results['meta']    ||= {}
    results['unicast'] ||= {}
    versions.each do |version|
      check_version(model, version, client_id, results['unicast'])
    end
    results['meta']['preSync'] = true
  end

  def check_version(model, version, client_id, results)
    results['update'] ||= {}
    object = model.find_by_remote_id(version['id'])
    if object
      # Discard update if obsolete
      if object.remote_version.obsoletes? version['version'], client_id
        false
      # File update for rebase if server version supersedes client version
      elsif object.remote_version.supersedes? version['version']
        add_update_for(object, results)
        false
      # Process the update
      else
        [true, object]
      end
    else
      true
    end
  end

  def handle_creates(model, creates, results)

  end

  def handle_updates(model, updates, client_id, results)
    results['unicast']   ||= {}
    results['multicast'] ||= {}
    updates.select do |update|
      success, object = check_version(model, update, client_id, results['unicast'])
      if success
        process_update(model, object, update, results['multicast'])
      end
    end
  end

  def process_update(model, object, update, successful_updates)
    object ||= model.new
    object.update_attribute(:remote_id, update['id']) unless object.remote_id.present?
    object.update_attributes(update['attributes'])
    object.update_attribute(:remote_version, update['version'])
    if object.valid?
      add_update_for(object, successful_updates)
    end
  end

  def add_update_for(object, results)
    results['update'] ||= {}
    results['update'][object.remote_id] = json_for(object)
  end

  def json_for(object)
    object.attributes.reject do |key, value|
      ['id', 'remote_id'].include? key.to_s
    end
  end

  def publish_results(message, results)
    multicast_channel = "/sync/#{message['model_name']}"
    @client.publish(multicast_channel, results['multicast'])
    if message['client_id'].present?
      unicast_channel = "#{multicast_channel}/#{message['client_id']}"
      @client.publish(unicast_channel, results['unicast'])
    end
  end

  def publish
    EM.add_periodic_timer(360) {
      @client.publish('/sync/some_channel', 'hello' => 'world')
    }
  end
end