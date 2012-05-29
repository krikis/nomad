@Versioning =
  initVersioning: ->
    @_versioning ||= {}
    unless @_versioning.oldVersion?
      previous = CryptoJS.SHA256(JSON.stringify @previousAttributes()).toString()
      @_versioning.oldVersion = previous
    @setVersion()
      
  isFresh: ->
    not @_versioning?.synced

  hasPatches: ->
    @_versioning?.patches?.size() > 0
    
  oldVersion: ->
    @_versioning?.oldVersion
    
  version: ->
    @_versioning?.version

  addPatch: ->
    @initVersioning()
    if @hasChanged() and @_versioning.synced
      @_versioning.patches ||= _([])
      @_versioning.patches.push @createPatch()
      @setVersion()

  createPatch: ->
    @dmp = new diff_match_patch
    diff = @dmp.diff_main JSON.stringify(@previousAttributes()),
                          JSON.stringify(@)
    patch = @dmp.patch_make JSON.stringify(@previousAttributes()),
                            diff
    @dmp.patch_toText(patch)

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
    patches.all (patch_text) =>
      @applyPatch(patch_text)

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
      
  resetVersioning: ->
    @_versioning.patches = _([])
    @_versioning.oldVersion = @_versioning.version
    @setVersion()

# extend Backbone.Model
_.extend Backbone.Model::, @Versioning


