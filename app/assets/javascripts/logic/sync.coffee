@Sync =
  preSync: ->
    @fayeClient.publish
      versions: @versionDetails(markSynced: true)
        
  versionDetails: (options = {}) ->
    _(@models).chain().map((model) ->
      details = 
        id: model.id
        version: model.version()
      details['is_new'] = true unless model.isSynced()
      model.markAsSynced() if options.markSynced
      details
    ).value()
    
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