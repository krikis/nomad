@Versioning =
  initVersioning: ->
    @_versioning ||= {}
    @_versioning.vector ||= new VectorClock
    @_versioning.vector[Nomad.clientId] ||= 0
    
  version: ->
    @_versioning?.vector

  tickVersion: ->
    @_versioning.vector[Nomad.clientId] += 1
    
  localClock: ->
    @_versioning.vector[Nomad.clientId]

  addPatch: ->
    @initVersioning()
    @_versioning.patches ||= _([])
    @_versioning.patches.push @createPatch(@localClock())
    @tickVersion()

  createPatch: (base) ->
    @dmp = new diff_match_patch
    diff = @dmp.diff_main JSON.stringify(@previousAttributes()),
                          JSON.stringify(@)
    patch = @dmp.patch_make JSON.stringify(@previousAttributes()),
                            diff
    patch_text: @dmp.patch_toText(patch)
    base: base

  hasPatches: ->
    @_versioning?.patches?.size() > 0  
    
  markAsSynced: ->
    @_versioning.synced = true  
    
  isSynced: ->
    @_versioning?.synced
    
  handleUpdate: (attributes) ->
    handler = @checkVersion(attributes['remote_version'])
    @[handler] attributes
    
  checkVersion: (remoteVersion) ->
    # if the client receives an acknowledgement from the server
    if @version().equals(remoteVersion) or @version().supersedes(remoteVersion)
      'forwardTo'
    # if the client receives a conflicting update from the server
    else if @version().conflictsWith(remoteVersion)
      'rebase'
    # if the server version supersedes the client version
    else
      'update'

  rebase: (attributes) ->
    version = attributes.remote_version
    delete attributes.remote_version
    dummy = new @constructor
    dummy.set attributes
    if dummy.processPatches(@_versioning.patches)
      @set dummy
      @updateVersionTo(version)
      return @
    false
    
  updateVersionTo: (version) ->    
    vector = @_versioning.vector
    _.each version, (value, clock) ->
      if not vector[clock]? or value > vector[clock]
        vector[clock] = value 

  processPatches: (patches) ->
    patches.all (patch) =>
      @applyPatch(patch.patch_text)

  applyPatch: (patch_text) ->
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
      
  forwardTo: (vectorClock) ->
    patches = @_versioning.patches
    while @hasPatches() and patches.first().base < vectorClock[Nomad.clientId]
      patches.shift() 
    
# extend Backbone.Model
_.extend Backbone.Model::, @Versioning


