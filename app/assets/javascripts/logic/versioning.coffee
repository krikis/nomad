@Versioning = 
  initVersioning: ->
    @_versioning ||= {}
    @_versioning.oldVersion ||= CryptoJS.SHA256(JSON.stringify @previousAttributes()).toString()
    
  hasPatches: ->
    @_versioning?.patches?.size() > 0

  addPatch: ->
    if @get('synced')
      @initVersioning()
      @_versioning.patches ||= _([])
      @_versioning.patches.push @createPatch()

  createPatch: ->
    window.dmp ||= new diff_match_patch
    @dmp = window.dmp
    diff = @dmp.diff_main JSON.stringify(@previousAttributes()), JSON.stringify(@)
    patch = @dmp.patch_make JSON.stringify(@previousAttributes()), diff
    @dmp.patch_toText(patch)
    
# extend Backbone.Model
_.extend Backbone.Model::,  @Versioning