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

  # clean up all recorded changes preceding the received data version
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

  # process update received from the server
  processUpdate: (attributes) ->
    # fetch update method
    method = @_updateMethod(attributes['remote_version'])
    # process the update
    @[method] attributes

  # determine which update strategy to use
  _updateMethod: (remoteVersion) ->
    switch @_checkVersion(remoteVersion)
      when 'supersedes' then '_forwardTo'
      when 'conflictsWith' then '_rebase'
      when 'precedes' then '_update'

  # resolve a conflicting update by rebasing it on a new data version
  _rebase: (attributes) ->
    # remove all obsolete entries from the browser log
    @_forwardTo(attributes)
    [version, created_at, updated_at] =
      @_extractVersioning(attributes)
    dummy = new @constructor
    dummy.set attributes
    # attempt to apply all recorded patches to the new data
    if @_applyPatchesTo dummy
      # persist the result of re-executing the local update
      @set dummy, skipPatch: true
      # update the local data version to include the new data version
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

  # apply recorded patches to new version of the data
  _applyPatchesTo: (dummy) ->
    # if the incremental log is used
    if @versioning == 'structured_content_diff'
      patches = _(@_versioning.patches)
      # apply all patches to the new data
      patches.all (patch) =>
        dummy._applyPatch(patch.patch_text)
    # if a merged diff object is used
    else
      patcher = new Patcher @
      # apply it to the data
      patcher.applyPatchesTo(dummy)

  # apply a patch to the model
  _applyPatch: (patch_text) ->
    dmp = new diff_match_patch
    dmp.Match_Threshold = 0.3
    # deserialize the patch
    patch = dmp.patch_fromText(patch_text)
    # sort the model data properties to prevent artificial conflicts
    sorted_attributes = @_sortPropertiesIn @attributes
    json = JSON.stringify(sorted_attributes)
    # apply the patch
    [new_json, results] = dmp.patch_apply(patch, json)
    if false not in results
      patched_attributes = JSON.parse(new_json)
      # save the re-executed update
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

  # update the model to reflect the update pushed from the server
  _update: (attributes) ->
    [version, created_at, updated_at] =
      @_extractVersioning(attributes)
    @set attributes, skipPatch: true
    # update vector clock to contain remote clock updates
    @_updateVersionTo(version, updated_at)
    @save()
    null

# extend Backbone.Model
_.extend Backbone.Model::, @Versioning


