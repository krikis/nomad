#= require_tree ./logic
#= require_self
#= require_tree ../templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

_.extend Backbone.View::, @LinkHandler

window.Nomad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  