#= require_tree ./logic
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

_.extend Backbone.View::,   @LinkHandler
_.extend Backbone.View::,   @Observer
_.extend Backbone.View::,   @Composition
_.extend Backbone.Router::, @Swapper

window.Nomad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  