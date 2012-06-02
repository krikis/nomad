@Versioning =
  initVersioning: ->
    @_versioning ||= {}
    unless @_versioning.oldVersion?
      previous = CryptoJS.SHA256(JSON.stringify @previousAttributes()).toString()
      @_versioning.oldVersion = previous

  markAsSynced: ->
    @initVersioning() unless @_versioning
    @_versioning.synced = true
      
  isSynced: ->
    @_versioning?.synced

  hasPatches: ->
    @_versioning?.patches?.size() > 0
    
  oldVersion: ->
    @_versioning?.oldVersion
    
  version: ->
    @_versioning?.version || @_versioning?.oldVersion

  addPatch: ->
    @initVersioning()
    if @hasChanged()
      @setVersion()
      if @_versioning.synced
        @_versioning.patches ||= _([])
        @_versioning.patches.push @createPatch(@oldVersion())

  createPatch: (base) ->
    @dmp = new diff_match_patch
    diff = @dmp.diff_main JSON.stringify(@previousAttributes()),
                          JSON.stringify(@)
    patch = @dmp.patch_make JSON.stringify(@previousAttributes()),
                            diff
    patch_text: @dmp.patch_toText(patch)
    base: base
    

  setVersion: ->
    @_versioning.version = CryptoJS.SHA256(JSON.stringify @).toString()

  rebase: (attributes) ->
    dummy = new @constructor
    dummy.set attributes
    if dummy.processPatches(@_versioning.patches)
      @set dummy
      return @
    false

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
      
  forwardTo: (version) ->
    @_versioning.oldVersion = version
    if @hasPatches() and patches = @_versioning.patches
      patches.shift() while patches.first().base != version
    
# extend Backbone.Model
_.extend Backbone.Model::, @Versioning


