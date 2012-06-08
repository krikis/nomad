@Versioning =
  initVersioning: ->
    @_versioning ||= {}
    @_versioning.vector ||= new VectorClock
    @_versioning.vector[Nomad.clientId] ||= 0
    
  version: ->
    @_versioning?.vector

  addPatch: ->
    @initVersioning()
    @_versioning.patches ||= _([])
    @_versioning.patches.push @_createPatch(@_localClock())
    @_tickVersion()
    
  _localClock: ->
    @_versioning.vector[Nomad.clientId]

  _createPatch: (base) ->
    @dmp = new diff_match_patch
    diff = @dmp.diff_main JSON.stringify(@previousAttributes()),
                          JSON.stringify(@)
    patch = @dmp.patch_make JSON.stringify(@previousAttributes()),
                            diff
    patch_text: @dmp.patch_toText(patch)
    base: base

  _tickVersion: ->
    @_versioning.vector[Nomad.clientId] += 1

  hasPatches: ->
    @_versioning?.patches?.size() > 0  
    
  markAsSynced: ->
    @_versioning.synced = true  
    
  isSynced: ->
    @_versioning?.synced
    
  handleUpdate: (attributes) ->
    handler = @_checkVersion(attributes['remote_version'])
    @[handler] attributes
    
  _checkVersion: (remoteVersion) ->
    # if the client receives an acknowledgement from the server
    if @version().equals(remoteVersion) or @version().supersedes(remoteVersion)
      '_forwardTo'
    # if the client receives a conflicting update from the server
    else if @version().conflictsWith(remoteVersion)
      '_rebase'
    # if the server version supersedes the client version
    else
      '_update'
      
  _forwardTo: (attributes) ->
    vectorClock = attributes.remote_version
    patches = @_versioning.patches
    while @hasPatches() and patches.first().base < vectorClock[Nomad.clientId]
      patches.shift()
    @save()

  _rebase: (attributes) ->
    version = attributes.remote_version
    delete attributes.remote_version
    dummy = new @constructor
    dummy.set attributes
    if dummy._processPatches(@_versioning.patches)
      @set dummy
      @_updateVersionTo(version)
      @save()
      return @
    false

  _processPatches: (patches) ->
    patches.all (patch) =>
      @_applyPatch(patch.patch_text)

  _applyPatch: (patch_text) ->
    @dmp = new diff_match_patch
    patch = @dmp.patch_fromText(patch_text)
    json = JSON.stringify(@)
    [new_json, results] = @dmp.patch_apply(patch, json)
    if not false in results
      patched_attributes = JSON.parse(new_json)
      @set patched_attributes
      true
    else
      false

  _updateVersionTo: (version) ->    
    vector = @_versioning.vector
    _.each version, (value, clock) ->
      if not vector[clock]? or value > vector[clock]
        vector[clock] = value
        
  _update: (attributes) ->
    version = attributes.remote_version
    delete attributes.remote_version
    @set attributes
    @_updateVersionTo(version)
    @save()
    
# extend Backbone.Model
_.extend Backbone.Model::, @Versioning


