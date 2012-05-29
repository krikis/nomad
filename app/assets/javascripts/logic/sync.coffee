@Sync =
  prepareSync: ->
    if not _.isEmpty(changed = @changedModels())
      @fayeClient.publish
        model_name: @modelName
        changed: changed      

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
    @syncModels _(updated).compact()
    
  syncModels: (updated) ->
    fresh = @freshModels()
    # if not (_.isEmpty(updated) and _.isEmpty(fresh))
    @fayeClient.publish
      model_name: @modelName
      updates: updated
      creates: fresh
    
  freshModels: () ->
    _(@models).chain().map((model) ->
      if model.isFresh()
        model: JSON.stringify(model)
        version: model.version()
    ).compact().value()

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync