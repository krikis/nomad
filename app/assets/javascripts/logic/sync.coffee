@Sync = 
  prepareSync: ->
    @fayeClient.publish {}
    
# extend Backbone.Collection
_.extend Backbone.Collection::, Sync