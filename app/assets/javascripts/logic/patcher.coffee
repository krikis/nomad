class @Patcher

  constructor: (model) ->
    @model = model

  # update the merged diff object o reflect the latest data change
  updatePatches: ->
    # initialize diff object should it fail to exist
    if not (patch = _.last @model.patches()) or
       (patch.base + 1) in @model.syncingVersions()
      @model.patches().push
        _patch: {}
        base: @model.localClock() || 0
    # update the diff object to reflect the latest changes
    @_updatePatchFor(_.last(@model.patches())._patch,
                     @model.changedAttributes(),
                     @model.previousAttributes())

  # update merged diff object to reflect current change
  _updatePatchFor: (patch, changed, previous = {}) ->
    _.each changed, (value, attribute) =>
      previousValue = previous[attribute]
      # when the property did not change before
      if not _.has(patch, attribute)
        # and the original value was a nested object
        if _.isObject(previousValue)
          # record an empty object
          patch[attribute] = {}
        # and a data diff is required
        else if _.isString(previousValue)
          # record the original value
          patch[attribute] = previousValue
        # and only the fact a change occurred is relevant
        else
          # just record the property key
          patch[attribute] = null
      # when recursion is indicated
      if _.isObject(patch[attribute]) and
         _.isObject(previousValue) and
         _.isObject(value)
        # calculate the set of changed properties in the nested object
        changedAttributes = @_changedAttributes(changed[attribute],
                                                previousValue)
        # and update the merged diff object for these changes
        @_updatePatchFor(patch[attribute],
                         changedAttributes,
                         previousValue)

  _changedAttributes: (now, previous = {}) ->
    changed = {}
    attributes = _.union(_.properties(now), _.properties(previous))
    _.each attributes, (attribute) ->
      unless _.isEqual(previous[attribute], now[attribute])
        changed[attribute] = now[attribute]
    changed

  applyPatchesTo: (dummy) ->
    @dmp = new diff_match_patch
    @dmp.Diff_Timeout = 0
    @dmp.Match_Threshold = 0.3
    mergedPatch = @_mergePatches @model.patches()
    @_applyPatch(mergedPatch,
                 dummy.attributes,
                 @model.attributes)

  _mergePatches: (patches = []) ->
    patches = _.clone patches
    merged = _.deepClone patches.shift()?._patch
    _.each patches, (patch) =>
      @_mergeInto merged, patch._patch
    merged

  _mergeInto: (patch, source) ->
    _.each source, (value, attribute) =>
      if not _.has(patch, attribute) or _.isObject(patch[attribute])
        if _.isObject(value)
          patch[attribute] ||= {}
          @_mergeInto(patch[attribute], value)
        else if not _.isObject(patch[attribute])
          patch[attribute] = value

  # apply the recorded merged diff to the new data version
  _applyPatch: (patch, attributesToPatch, currentAttributes) ->
    # for each data property
    result = _.map patch, (originalValue, attribute) =>
      currentValue  = currentAttributes[attribute]
      # patch it with the diff between the original and current value
      @_patchAttribute(attribute, attributesToPatch,
                       originalValue, currentValue)
    false not in result

  # patch an attribute given the original and current value
  _patchAttribute: (attribute, attributesToPatch,
                    originalValue, currentValue) ->
    if _.isString(currentValue)
      # when a diff can be generated
      if _.isString(originalValue) and
         _.isString(attributesToPatch[attribute])
        # patch attribute with diff between original and current
        @_patchStringAttribute(attribute, attributesToPatch,
                               originalValue, currentValue)
      else
        attributesToPatch[attribute] = currentValue
        true
    else if _.isObject(currentValue)
      objectToPatch = attributesToPatch[attribute]
      # when recursion is indicated
      if _.isObject(originalValue) and _.isObject(objectToPatch)
        # patch the attributes of the nested data object
        @_applyPatch(originalValue, objectToPatch, currentValue)
      else
        attributesToPatch[attribute] = currentValue
        true
    # when only the change itself is relevant
    else
      # apply the current value
      attributesToPatch[attribute] = currentValue
      true

  # patch a string attribute given the original and current value
  _patchStringAttribute: (attribute, attributesToPatch,
                          originalValue, currentValue) ->
    # apply the patch
    [patched_value, results] = @_patchString(originalValue, currentValue,
                                             attributesToPatch[attribute])
    if false in results
      # apply the patch in reverse order
      [patched_value, results] = @_patchString(originalValue, 
                                               attributesToPatch[attribute],
                                               currentValue)
    if false not in results
      # set the new value on success
      attributesToPatch[attribute] = patched_value
      true
    else    
      # keep the current value when patching fails
      attributesToPatch[attribute] = currentValue
      # TODO: handle failed patch
      false

  # patch a string value using the diff
  # of the original and current value
  _patchString: (originalValue, currentValue, valueToPatch) ->
    # calculate the diff and patch
    diff = @dmp.diff_main originalValue,
                          currentValue
    patch = @dmp.patch_make originalValue,
                            diff
    # apply the patch
    @dmp.patch_apply patch, valueToPatch




