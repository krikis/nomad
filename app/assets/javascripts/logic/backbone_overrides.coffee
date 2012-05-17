# Override the Backbone.Model constructor and add the
# on change @addPatch versioning callback to it
Backbone.Model = ((Model) ->
  # Define the new constructor
  Backbone.Model = (attributes, options) ->
    Model.apply @, arguments
    @on 'change', @addPatch, @
    return
  # Clone static properties
  _.extend(Backbone.Model, Model)
  # Clone prototype
  Backbone.Model:: = ((Prototype) ->
    Prototype:: = Model::
    new Prototype
  )(->)
  # Update constructor in prototype
  Backbone.Model::constructor = Backbone.Model
  Backbone.Model
) Backbone.Model

# Make sure the collection uses the new Backbone.Model
# constructor when creating a model
_.extend Backbone.Collection::
  model: Backbone.Model

# Override the Backbone.Collection constructor and add
# instantiating the faye_client to it
Backbone.Collection = ((Collection) ->
  # Define the new constructor
  Backbone.Collection = (models, options = {}) ->
    Collection.apply @, arguments
    @channel = options.channel
    @channel ||= @constructor.name.toLowerCase()
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