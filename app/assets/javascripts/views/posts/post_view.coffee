Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.PostView extends Backbone.View
  template: JST["posts/post"]

  events:
    'click .show':    'show'
    'click .edit':    'edit'
    'click .destroy': 'destroy'

  tagName: "tr"  

  show : (e) -> 
    e.preventDefault()
    Backbone.history.navigate $(e.target).attr("href"), trigger: true

  edit : (e) -> 
    e.preventDefault()
    Backbone.history.navigate $(e.target).attr("href"), trigger: true

  destroy: () ->
    @model.destroy()
    @remove()
    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
