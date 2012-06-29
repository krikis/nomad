# Override the Backbone.Model constructor and add the
# on change @addVersion versioning callback to it
Backbone.Model = ((Model) ->
  # Define the new constructor
  Backbone.Model = (attributes, options) ->
    @clientId ||= Nomad.clientId
    Model.apply @, arguments
    @on 'change', @addVersion, @
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
    @clientId ||= options.clientId
    @clientId ||= Nomad.clientId
    @url ||= "/#{@constructor.name.underscore()}"
    @modelName ||= options.modelName
    @modelName ||= @model::constructor.name
    unless @modelName? and @modelName.length > 0
      throw new Error('Model name undefined: either set a valid Backbone.Model ' +
                      'or pass a modelName option!')
    @fayeClient ||= new BackboneSync.FayeClient(@)
    @localStorage ||= new Backbone.LocalStorage(@modelName)
    Collection.apply @, arguments
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