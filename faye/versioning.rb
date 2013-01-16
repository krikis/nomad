module Faye::Versioning

  def handle_new_versions(model, new_versions, results)
    new_versions.each do |version|
      check_new_version(model, version, results)
    end
    results['meta']['preSync'] = true
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
      check_version(model, version, client_id, results)
    end
    results['meta']['preSync'] = true
  end

  # compare the local data version with the version in the master data copy
  def check_version(model, version, client_id, results)
    object = model.find_by_remote_id(version['id'])
    # if the data object already exists on the server
    if object
      # is the update obsolete? -> discard it
      if object.remote_version.obsoletes? version['version'], client_id
        false
      # does the update conflict? -> report it
      elsif object.remote_version.supersedes? version['version']
        add_update_for(object, results)
        false
      # else -> persist the update!
      else
        [true, object]
      end
    # apparently the data object does not (yet) exist in the master copy
    else
      true
    end
  end

end