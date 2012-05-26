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
    window.dmp ||= new diff_match_patch
    @dmp = window.dmp
    diff = @dmp.diff_main JSON.stringify(@previousAttributes()), 
                          JSON.stringify(@)
    patch = @dmp.patch_make JSON.stringify(@previousAttributes()), 
                            diff
    @dmp.patch_toText(patch)
    
  setVersion: ->  
    @_versioning.version = CryptoJS.SHA256(JSON.stringify @).toString()
    
    
# extend Backbone.Model
_.extend Backbone.Model::,  @Versioning