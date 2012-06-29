class @ModelPatch
    
  updateFor: (changed, previous) ->
    @_patch = @_updatePatchFor(@_patch, changed, previous)
    
  _updatePatchFor: (patch, changed, previous) ->
    newPatch = not patch?
    patch ||= {}
    previous ||= {}
    _.each changed, (value, attribute) =>
      if _.isString value
        patch[attribute] = previous[attribute] if newPatch
      else if _.isObject value
        patch[attribute] = @_updatePatchFor(patch[attribute],
                                            changed[attribute],
                                            previous[attribute])
      else
        patch[attribute] = changed[attribute]
    patch
    