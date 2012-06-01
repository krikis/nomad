@Sync =
  preSync: ->
    fresh = @freshModels()
    changed = @changedModels()
    if not (_.isEmpty(fresh) and _.isEmpty(changed))
      @fayeClient.publish
        creates: fresh
        changes: changed

  freshModels: () ->
    _(@models).chain().map((model) ->
      if model.isFresh()
        window.m = model
        json = model.toJSON()
        delete json.id
        id: model.id
        attributes: JSON.stringify(json)
        version: model.version()
    ).compact().value()

  changedModels: ->
    _(@models).chain().map((model) ->
      if model.hasPatches()
        id: model.id
        old_version: model.oldVersion()
    ).compact().value()
    
  processUpdates: (models) ->
    updated = _.map models, (attributes, id) =>
      model = @get(id)
      model?.rebase attributes
    @syncUpdates _(updated).compact()
    
  syncUpdates: (updated) ->
    @fayeClient.publish
      updates: updated
    
# extend Backbone.Collection
_.extend Backbone.Collection::, Sync