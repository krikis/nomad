module Faye::Sync

  def process_message(model, message)
    results = init_results
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
    results
  end

  def init_results
    time = Time.now
    {'unicast'   => {'meta'    => {'timestamp' => time},
                     'resolve' => [],
                     'update'  => {}},
     'multicast' => {'meta'    => {'timestamp' => time}                ,
                     'create'  => {},
                     'update'  => {}}}
  end

  def add_update_for(object, results)
    results['update'][object.remote_id] = json_for(object)
  end

  def handle_creates(model, creates, results)
    creates.each do |create|
      if check_new_version(model, create, results['unicast'])
        process_create(model, create, results['multicast'])
      end
    end
  end

  def process_create(model, create, successful_creates)
    object = model.new
    set_attributes(object, create, successful_creates['meta']['timestamp'])
    if object.valid?
      add_create_for(object, successful_creates)
    end
  end

  def set_attributes(object, attributes, last_update = nil)
    unless object.remote_id.present?
      object.update_attribute(:remote_id, attributes['id'])
    end
    object.update_attributes(attributes['attributes'])
    object.update_attribute(:remote_version, attributes['version'])
    object.update_attribute(:last_update, last_update) if last_update
    object.update_attribute(:created_at, attributes['created_at'])
    object.update_attribute(:updated_at, attributes['updated_at'])
  end

  def add_create_for(object, results)
    results['create'][object.remote_id] = json_for(object)
  end

  def handle_updates(model, updates, client_id, results)
    updates.each do |update|
      success, object = check_version(model, update, client_id, results['unicast'])
      if success
        process_update(model, object, update, results['multicast'])
      end
    end
  end

  def process_update(model, object, update, successful_updates)
    object ||= model.new
    set_attributes(object, update, successful_updates['meta']['timestamp'])
    if object.valid?
      add_update_for(object, successful_updates)
    end
  end

  def json_for(object)
    object.attributes.reject do |key, value|
      ['id', 'remote_id', 'last_update'].include? key.to_s or value.nil?
    end
  end

  def add_missed_updates(timestamp, results)

  end

end
