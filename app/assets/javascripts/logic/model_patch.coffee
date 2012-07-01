class @ModelPatch
    
  constructor: (base, changed, previous) ->
    @base = base
    @_patch = @_createPatchFor(changed, previous)
    
  _createPatchFor: (changed, previous) ->
    patch = _.clone(changed)
    previous ||= {}
    _.each changed, (value, attribute) =>
      if _.isString(value)
        patch[attribute] = previous[attribute]
      else if _.isObject(value)
        patch[attribute] = @_createPatchFor(changed[attribute],
                                            previous[attribute])
    patch
    
  applyPatchTo: (model, first, currentAttributes) ->
    @dmp = new diff_match_patch
    @_applyPatch(@_patch, model, first._patch, currentAttributes)
    
  _applyPatch: (patch, model, firstAttributes, currentAttributes) ->
    _.each patch, (value, attribute) =>
      currentValue = currentAttributes[attribute]
      if _.isString(currentValue)
        originalValue = firstAttributes[attribute]
        if _.isString(originalValue)
          diff = @dmp.diff_main originalValue,
                                currentValue
      else if _.isObject(currentValue)
      
      else
        model.set(attribute, currentValue, skipPatch: true)
    