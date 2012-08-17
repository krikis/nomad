class @Patcher

  constructor: (model) ->
    @model = model

  # update the merged diff object o reflect the latest data change
  updatePatches: ->
    # initialize diff object should fail to exist
    if not (patch = @model.patches()[0]) or
       patch.base in @model.syncingVersions()
      @model.patches().push
        _patch: {}
        base: @model.localClock() || 0
    # update the diff object to reflect the latest changes
    @_updatePatchFor(_.last(@model.patches())._patch,
                     @model.changedAttributes(),
                     @model.previousAttributes())

  # update diff object to reflect current change
  _updatePatchFor: (patch, changed, previous = {}) ->
    _.each changed, (value, attribute) =>
      # when the property change has not been recorded before
      # or recursion is indicated
      if not _.has(patch, attribute) or _.isObject(patch[attribute])
        # when a data diff rather than the data change itself is needed
        if _.isString(value) and not _.isObject(patch[attribute])
          # record the original value
          patch[attribute] = previous[attribute]
        # when recursion is indicated
        else if _.isObject(value)
          # calculate the set of changed properties in the nested object
          changedAttributes = @_changedAttributes(changed[attribute],
                                                  previous[attribute])
          patch[attribute] ||= {}
          # update the patch for the nested object
          @_updatePatchFor(patch[attribute],
                           changedAttributes,
                           previous[attribute])
        # if only the data change has to be recorded
        else if not _.isObject(patch[attribute])
          # just store the property key
          patch[attribute] = null

  _changedAttributes: (now, previous = {}) ->
    changed = {}
    attributes = _.union(_.keys(now), _.keys(previous))
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
      if _.isString(originalValue) and _.isString(attributesToPatch[attribute])
        # patch attribute with diff between original and current
        @_patchString(attribute, attributesToPatch,
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
      attributesToPatch[attribute] = currentValue
      # TODO: handle failed patch
      false




