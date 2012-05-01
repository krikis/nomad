Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.ShowView extends Backbone.View
  template: JST["posts/show"]
  
  events:
    "click .index" : "index"
    "click .edit" : "index"

  index : (e) -> 
    @followLink e

  edit : (e) -> 
    @followLink e

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    @
