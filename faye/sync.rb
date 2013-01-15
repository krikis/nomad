module Faye::Sync

  # collect all updates since the last synchronization phase
  def add_missed_updates(model, message)
    lamport_clock = message['last_synced']
    results = init_results(message)
    # query all updates since the timestamp if present
    objects = if lamport_clock
      model.where(['last_update > ?', lamport_clock])
    # else query all models
    else
      model.all
    end
    # file all updates for unicast
    objects.each do |object|
      add_update_for(object, results['unicast'])
    end
    results
  end

  def init_results(message = {})
    {'unicast'   => {'meta'    => {'client' => message['client_id'],
                                   'unicast' => true},
                     'resolve' => [],
                     'update'  => {}},
     'multicast' => {'meta'    => {'client' => message['client_id']},
                     'create'  => {},
                     'update'  => {}}}
  end

  # process a synchronization message
  def process_message(model, message, results)
    # detect guid conflicts for models that were never synced before
    if message['new_versions'].present?
      handle_new_versions(model, message['new_versions'], results)
    end
    # detect update conflicts for previously synced models
    if message['versions'].present?
      handle_versions(model,
                      message['versions'],
                      message['client_id'],
                      results)
    end
    # add newly created model to master data copy
    if message['creates'].present?
      handle_creates(model, message['creates'], message['model_name'], results)
    end
    # add local update of model to master data copy
    if message['updates'].present?
      handle_updates(model,
                     message['updates'],
                     message['client_id'],
                     message['model_name'],
                     results)
    end
  end

  def add_update_for(object, results)
    results['update'][object.remote_id] ||= json_for(object)
  end

  def handle_creates(model, creates, model_name, results)
    creates.each do |create|
      if check_new_version(model, create, results['unicast'])
        process_create(model, create, model_name, results['multicast'])
      end
    end
  end

  def process_create(model, create, model_name, successful_creates)
    successful_creates['meta']['timestamp'] ||= LamportClock.tick model_name
    object = model.new
    model.transaction do
      set_attributes(object, create, successful_creates['meta']['timestamp'])
    end
    if object.valid?
      add_create_for(object, successful_creates)
    end
  end

  # persist the local update on the master data copy
  def set_attributes(object, attributes, last_update = nil)
    # persist the GUID
    unless object.remote_id.present?
      object.update_attribute(:remote_id, attributes['id'])
    end
    # persist the actual data
    object.update_attributes(attributes['attributes'])
    # persist the data version and last_update timestamp
    object.update_attribute(:remote_version, attributes['version'])
    object.update_attribute(:last_update, last_update) if last_update
    # persist the lifecycle timestamps
    object.update_attribute(:created_at, attributes['created_at'])
    object.update_attribute(:updated_at, attributes['updated_at'])
  end

  def add_create_for(object, results)
    results['create'][object.remote_id] = json_for(object)
  end

  def handle_updates(model, updates, client_id, model_name, results)
    updates.each do |update|
      model.transaction do
        success, object = check_version(model, update,
                                        client_id, results['unicast'])
        if success
          process_update(model, object, update, model_name, results['multicast'])
        end
      end
    end
  end

  def process_update(model, object, update, model_name, successful_updates)
    successful_updates['meta']['timestamp'] ||= LamportClock.tick model_name
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

end
