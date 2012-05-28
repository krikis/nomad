@Versioning =
  initVersioning: ->
    @_versioning ||= {}
    unless @_versioning.oldVersion?
      previous = CryptoJS.SHA256(JSON.stringify @previousAttributes()).toString()
      @_versioning.oldVersion = previous

  hasPatches: ->
    @_versioning?.patches?.size() > 0

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
    @_versioning.patches.each (patch_text) =>
      dummy.applyPatch(patch_text)
      
  applyPatch: (patch_text) ->    
    @dmp = new diff_match_patch
    patch = @dmp.patch_fromText(patch_text)
    dummy_json = JSON.stringify(@)

      

# extend Backbone.Model
_.extend Backbone.Model::,  @Versioning