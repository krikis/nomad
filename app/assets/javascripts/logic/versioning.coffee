@Versioning = 

  initialize: (attributes, options) ->
    @on 'change', @addPatch, @
    
  addPatch: ->
    if @get('synced')
      @_patches ||= _([])
      @_patches.push @createPatch()

  createPatch: ->
    window.dmp ||= new diff_match_patch
    @dmp = window.dmp
    diff = @dmp.diff_main JSON.stringify(@previousAttributes()), JSON.stringify(@)
    patch = @dmp.patch_make JSON.stringify(@previousAttributes()), diff
    @dmp.patch_toText(patch)