@Sync =
  preSync: ->
    @fayeClient.publish
      versions: @versionDetails()
        
  versionDetails: () ->
    _(@models).chain().map((model) ->
      id: model.id
      version: model.version()
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