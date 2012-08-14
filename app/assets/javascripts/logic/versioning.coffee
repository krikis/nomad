@Versioning =
  initVersioning: ->
    @_versioning ||= {}
    @_versioning.vector ||= new VectorClock
    @_versioning.vector[@clientId] ||= 0
    @_versioning.createdAt ||= (new Date).toJSON()

  createdAt: ->
    @_versioning?.createdAt

  version: ->
    @_versioning?.vector

  setVersion: (version, created_at, updated_at) ->
    vector = new VectorClock version
    @_versioning ||= {}
    @_versioning.createdAt = created_at
    @_versioning.updatedAt = updated_at
    @_versioning.vector = vector

  # update the data version and record the local change
  addVersion: (model, options = {}) ->
    unless options.skipPatch?
      # initialize data version
      @initVersioning()
      @_versioning.patches ||= []
      if @versioning == 'structured_content_diff'
        # append structured content diff to incremental browser log
        @_versioning.patches.push @_createPatch(@localClock())
      else
        # update existing merged log entry
        patcher = new Patcher(@)
        patcher.updatePatches()
      # increment local clock
      @_tickVersion()

  localClock: ->
    @_versioning.vector[@clientId]

  # create a patch based on a structured content diff
  _createPatch: (base) ->
    # sort properties to prevent artificial conflicts
    sorted_previous = @_sortPropertiesIn @previousAttributes()
    sorted_attributes = @_sortPropertiesIn @attributes
    dmp = new diff_match_patch
    dmp.Diff_Timeout = 0
    # create a diff between two versions of the model
    diff = dmp.diff_main JSON.stringify(sorted_previous),
                         JSON.stringify(sorted_attributes)
    patch = dmp.patch_make JSON.stringify(sorted_previous),
                           diff
    # return a persistence friendly version of the diff and the update base
    patch_text: dmp.patch_toText(patch)
    base: base

  _sortPropertiesIn: (object) ->
    return object unless _.isObject(object)
    sorted = {}
    keys = _.keys(object).sort()
    _.each keys, (key) =>
      sorted[key] = @_sortPropertiesIn object[key]
    sorted

  _tickVersion: ->
    @_versioning.vector[@clientId] += 1
    @_versioning.updatedAt = (new Date).toJSON()

  updatedAt: ->
    @_versioning?.updatedAt || @_versioning?.createdAt

  patches: ->
    @_versioning?.patches

  hasPatches: ->
    @_versioning?.patches?.length > 0

  syncingVersions: ->
    @_versioning?.syncingVersions || []

  markAsSynced: ->
    @_versioning.synced = true

  updateSyncingVersions: ->
    @_versioning.syncingVersions ||= []
    @_versioning.syncingVersions.push @localClock()

  isSynced: ->
    @_versioning?.synced

  processCreate: (attributes) ->
    method = @_createMethod(attributes['remote_version'])
    @[method] attributes

  _createMethod: (remoteVersion) ->
    switch @_checkVersion(remoteVersion)
      when 'supersedes' then '_forwardTo'
      when 'conflictsWith', 'precedes' then '_changeId'

  _checkVersion: (remoteVersion) ->
    # if the client receives an acknowledgement from the server
    if @version().equals(remoteVersion) or @version().supersedes(remoteVersion)
      'supersedes'
    # if the client receives a conflicting update from the server
    else if @version().conflictsWith(remoteVersion)
      'conflictsWith'
    # if the server version supersedes the client version
    else
      'precedes'

  _forwardTo: (attributes) ->
    vectorClock = attributes.remote_version
    patches = _(@_versioning.patches)
    while @hasPatches() and patches.first().base < vectorClock[@clientId]
      patches.shift()
    @_finishedSyncing(vectorClock)
    @save()
    null

  _finishedSyncing: (vectorClock) ->
    @_versioning.syncingVersions?.delete(vectorClock[@clientId])

  _changeId: (attributes) ->
    # TODO :: implement changing the model id when it conflicts
    # with a model created on another client
    # think about what to do with the user interface when this happens
    # return @

  processUpdate: (attributes) ->
    method = @_updateMethod(attributes['remote_version'])
    @[method] attributes

  _updateMethod: (remoteVersion) ->
    switch @_checkVersion(remoteVersion)
      when 'supersedes' then '_forwardTo'
      when 'conflictsWith' then '_rebase'
      when 'precedes' then '_update'

  _rebase: (attributes) ->
    @_forwardTo(attributes)
    [version, created_at, updated_at] =
      @_extractVersioning(attributes)
    dummy = new @constructor
    dummy.set attributes
    if @_applyPatchesTo dummy
      @set dummy, skipPatch: true
      @_updateVersionTo(version, updated_at)
      @save()
      return @
    else
      # TODO :: implement having user resolve conflict
    null

  _extractVersioning: (attributes) ->
    version = attributes.remote_version
    delete attributes.remote_version
    created_at = attributes.created_at
    delete attributes.created_at
    updated_at = attributes.updated_at
    delete attributes.updated_at
    [version, created_at, updated_at]

  _applyPatchesTo: (dummy) ->
    if @versioning == 'structured_content_diff'
      patches = _(@_versioning.patches)
      patches.all (patch) =>
        dummy._applyPatch(patch.patch_text)
    else
      patcher = new Patcher @
      patcher.applyPatchesTo(dummy)

  _applyPatch: (patch_text) ->
    dmp = new diff_match_patch
    dmp.Match_Threshold = 0.3
    patch = dmp.patch_fromText(patch_text)
    sorted_attributes = @_sortPropertiesIn @attributes
    json = JSON.stringify(sorted_attributes)
    [new_json, results] = dmp.patch_apply(patch, json)
    if false not in results
      patched_attributes = JSON.parse(new_json)
      @set patched_attributes
      true
    else
      false

  _updateVersionTo: (version, updated_at) ->
    @_versioning.updatedAt = updated_at
    vector = @_versioning.vector
    _.each version, (value, clock) ->
      if not vector[clock]? or value > vector[clock]
        vector[clock] = value

  _update: (attributes) ->
    [version, created_at, updated_at] =
      @_extractVersioning(attributes)
    @set attributes, skipPatch: true
    @_updateVersionTo(version, updated_at)
    @save()
    null

# extend Backbone.Model
_.extend Backbone.Model::, @Versioning


