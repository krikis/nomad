class @ModelPatch
    
  constructor: (base, changed, previous) ->
    @base = base
    @_patch = @_createPatchFor(changed, previous)
    
  _createPatchFor: (changed, previous) ->
    patch = _.clone(changed)
    previous ||= {}
    _.each changed, (value, attribute) =>
      if _.isString value
        patch[attribute] = previous[attribute]
      else if _.isObject value
        patch[attribute] = @_createPatchFor(changed[attribute],
                                            previous[attribute])
    patch
    
    