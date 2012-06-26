#= require_tree ./logic
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

# Create the Backbone application
@Nomad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  clientId: @clientId

