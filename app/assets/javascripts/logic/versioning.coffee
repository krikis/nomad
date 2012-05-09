@Versioning = 

  initialize: (attributes, options) ->
    @on 'change', @addPatch, @
    
  addPatch: (attributes, options)->
    if @get('synced')
      @_patches ||= _([])