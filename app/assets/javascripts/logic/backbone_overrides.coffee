# Override the Backbone.Collection constructor and add
# instantiating the faye_client to it
Backbone.Collection = ((Collection) ->
  # Define the new constructor
  Backbone.Collection = (models, options = {}) ->
    Collection.apply @, arguments
    @channel ||= options.channel
    @channel ||= @model::constructor.name
    unless @channel? and @channel.length > 0
      throw new Error('Channel undefined: either set a valid Backbone.Model ' +
                      'or pass a channel option!')
    @fayeClient = new BackboneSync.FayeClient(@,
      channel: @channel
    )
    return
  # Clone static properties
  _.extend(Backbone.Collection, Collection)
  # Clone prototype
  Backbone.Collection:: = ((Prototype) ->
    Prototype:: = Collection::
    new Prototype
  )(->)
  # Update constructor in prototype
  Backbone.Collection::constructor = Backbone.Collection
  Backbone.Collection
) Backbone.Collection