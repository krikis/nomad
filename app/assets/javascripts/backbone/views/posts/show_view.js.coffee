Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.ShowView extends Backbone.View
  template: JST["backbone/templates/posts/show"]
  
  events:
    "click .index" : "index"

  index : (e) -> 
    e.preventDefault()
    Backbone.history.navigate $(e.target).attr("href"), trigger: true

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
