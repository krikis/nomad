module Faye::Sync

  # initialize the results object
  def init_results(message = {})
    {'unicast'   => {'meta'    => {'client' => message['client_id'],
                                   'unicast' => true},
                     'resolve' => [],
                     'update'  => {}},
     'multicast' => {'meta'    => {'client' => message['client_id']},
                     'create'  => {},
                     'update'  => {}}}
  end

  # collect all updates since the last synchronization phase
  def add_missed_objects(model, message, results)
    lamport_clock = message['last_synced']
    # query all updates since the timestamp if present
    objects = if lamport_clock
      model.where(['last_update > ?', lamport_clock])
    # else query all models
    else
      model.all
    end
    # file all updates for unicast
    objects.each do |object|
      add_update_for(object, results)
    end
    # set the most recent lamport clock
    results['meta']['timestamp'] = objects.map(&:last_update).compact.max
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
      create_ids = handle_creates(model, message['creates'], results)
    end
    # add local update of model to master data copy
    if message['updates'].present?
      update_ids = handle_updates(model,
                               message['updates'],
                               message['client_id'],
                               results)
    end
    {:create_ids => create_ids, update_ids: update_ids}
  end

  def add_update_for(object, results)
    results['update'][object.remote_id] ||= json_for(object)
  end

  def json_for(object)
    object.attributes.reject do |key, value|
      ['id', 'remote_id', 'last_update'].include? key.to_s or value.nil?
    end
  end

  def handle_creates(model, creates, results)
    creates.map do |create|
      model.transaction do
        if check_new_version(model, create, results)
          process_create(model, create)
        end
      end
    end.compact
  end

  def process_create(model, create)
    object = model.new
    set_attributes(object, create)
    object.id if object.valid?
  end

  # persist the local update on the master data copy
  def set_attributes(object, attributes)
    # persist the GUID
    unless object.remote_id.present?
      object.update_attribute(:remote_id, attributes['id'])
    end
    # persist the actual data
    object.update_attributes(attributes['attributes'])
    # persist the data version and last_update timestamp
    object.update_attribute(:remote_version, attributes['version'])
    # persist the lifecycle timestamps
    object.update_attribute(:created_at, attributes['created_at'])
    object.update_attribute(:updated_at, attributes['updated_at'])
  end

  def handle_updates(model, updates, client_id, results)
    updates.map do |update|
      model.transaction do
        success, object = check_version(model, update,
                                        client_id, results)
        if success
          process_update(model, object, update)
        end
      end
    end.compact
  end

  def process_update(model, object, update)
    object ||= model.new
    set_attributes(object, update)
    object.id if object.valid?
  end

  def version_processed_objects(model, processed, model_name, results)
    model.transaction do
      unless processed[:create_ids].blank?
        timestamp = LamportClock.tick model_name
        model.where(:id => processed[:create_ids]).update_all(:last_update => timestamp)
      end
      unless processed[:update_ids].blank?
        timestamp ||= LamportClock.tick model_name
        model.where(:id => processed[:update_ids]).update_all(:last_update => timestamp)
      end
      results['meta']['timestamp'] = timestamp
    end
  end

  def add_processed_objects(model, processed, results)
    unless processed[:create_ids].blank?
      model.where(:id => processed[:create_ids]).each do |object|
        add_create_for(object, results)
      end
    end
    unless processed[:update_ids].blank?
      model.where(:id => processed[:update_ids]).each do |object|
        add_update_for(object, results)
      end
    end
  end

  def add_create_for(object, results)
    results['create'][object.remote_id] = json_for(object)
  end

end
