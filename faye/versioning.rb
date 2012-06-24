module Faye::Versioning

  def handle_new_versions(model, new_versions, results)
    new_versions.each do |version|
      check_new_version(model, version, results['unicast'])
    end
    results['unicast']['meta']['preSync'] = true
  end

  def check_new_version(model, new_version, results)
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
    versions.each do |version|
      check_version(model, version, client_id, results['unicast'])
    end
    results['unicast']['meta']['preSync'] = true
  end

  def check_version(model, version, client_id, results)
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

end