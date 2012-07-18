class @Patcher
    
  constructor: (model) ->
    @model = model
    
  updatePatches: ->
    @_cleanupPatches()
    @model.patches().push
      _patch: @_createPatchFor(@model.changedAttributes(), 
                               @model.previousAttributes())
      base: @model.localClock() || 0

  _cleanupPatches: () ->
    patches = _.clone @model.patches()
    _.each patches, (patch) =>
      unless patch == @model.patches()[0] or
             patch.base in @model.syncingVersions()
        @model.patches().delete patch
    
  _createPatchFor: (changed, previous = {}) ->
    patch = {}
    _.each changed, (value, attribute) =>
      if _.isString(value)
        patch[attribute] = previous[attribute]
      else if _.isObject(value)
        changedAttributes = @_changedAttributes(changed[attribute],
                                                previous[attribute])
        patch[attribute] = @_createPatchFor(changedAttributes,
                                            previous[attribute])
      else
        patch[attribute] = null
    patch
    
  _changedAttributes: (now, previous = {}) ->
    changed = {}
    attributes = _.union(_.keys(now), _.keys(previous))
    _.each attributes, (attribute) ->
      unless _.isEqual(previous[attribute], now[attribute])
        changed[attribute] = now[attribute]
    changed
      
  applyPatchesTo: (dummy) ->
    @dmp = new diff_match_patch
    patches = _(@model.patches())
    @_applyPatch(patches.last()._patch, 
                 dummy.attributes, 
                 patches.first()._patch, 
                 @model.attributes)
    
  _applyPatch: (patch, attributesToPatch, 
                firstAttributes, currentAttributes) ->
    _.all patch, (value, attribute) =>
      originalValue =   firstAttributes[attribute]
      currentValue  = currentAttributes[attribute]
      @_patchAttribute(attribute, value, attributesToPatch, 
                       originalValue, currentValue)
    
  _patchAttribute: (attribute, value, attributesToPatch, 
                    originalValue, currentValue) ->
    if _.isString(currentValue)
      if _.isString(originalValue)
        @_patchString(attribute, attributesToPatch, 
                      originalValue, currentValue)
      else
        attributesToPatch[attribute] = currentValue
        true
    else if _.isObject(currentValue)
      objectToPatch = attributesToPatch[attribute]
      if _.isObject(value) and _.isObject(objectToPatch)
        @_applyPatch(value, objectToPatch, originalValue, currentValue)
      else
        attributesToPatch[attribute] = currentValue
        true
    else
      attributesToPatch[attribute] = currentValue
      true
      
  _patchString: (attribute, attributesToPatch, originalValue, currentValue) ->    
    diff = @dmp.diff_main originalValue,
                          currentValue
    patch = @dmp.patch_make originalValue,
                            diff
    [patched_value, results] = @dmp.patch_apply patch, 
                                                attributesToPatch[attribute]
    if false not in results
      attributesToPatch[attribute] = patched_value
      true
    else
      # TODO: handle failed patch
      console.log 'Patching failed!!!'
      false
    
    
    
    
    