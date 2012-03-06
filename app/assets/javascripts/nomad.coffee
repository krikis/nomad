#= require_self
#= require_tree ../templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

_.templateSettings =
  evaluate: /\{\%([\s\S]+?)\%\}/g
  interpolate: /\{\{([\s\S]+?)\}\}/g
  escape: /\{\{\-([\s\S]+?)\}\}/g

window.Nomad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
