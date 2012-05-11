#= require_tree ./logic
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

# Override the Backbone.Model constructor and add the 
# on change @addPatch versioning callback to it
Backbone.Model = ((Model) ->
  Backbone.Model = (attributes, options) ->
    Model.apply @, arguments
    @on 'change', @addPatch, @
    return
  _.extend(Backbone.Model, Model)  
  _.extend(Backbone.Model::, Model::)
  Backbone.Model
) Backbone.Model
# Make sure the collection uses the new Backbone.Model 
# constructor when creating a model
_.extend Backbone.Collection:: 
  model: Backbone.Model
  
# Extend Backbone
_.extend Backbone.Model::,  @Versioning
_.extend Backbone.View::,   @LinkHandler
_.extend Backbone.View::,   @Observer
_.extend Backbone.View::,   @Composition
_.extend Backbone.Router::, @Swapper

# Create the Backbone application
window.Nomad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

