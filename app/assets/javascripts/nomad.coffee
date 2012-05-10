#= require_tree ./logic
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

Backbone.Model = ((Model) ->
  Backbone.Model = (attributes, options) ->
    Model.apply @, arguments
    @on 'change', @addPatch, @
    return
  _.extend(Backbone.Model, Model)  
  _.extend(Backbone.Model::, Model::)
  Backbone.Model
) Backbone.Model

_.extend Backbone.Collection:: 
  model: Backbone.Model
_.extend Backbone.Model::,  @Versioning
_.extend Backbone.View::,   @LinkHandler
_.extend Backbone.View::,   @Observer
_.extend Backbone.View::,   @Composition
_.extend Backbone.Router::, @Swapper

window.Nomad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

