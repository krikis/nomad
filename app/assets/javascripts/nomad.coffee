#= require_tree ./logic
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers
  
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

