Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.PostView extends Backbone.View
  template: JST["posts/post"]

  events:
    'click .show':    'show'
    'click .edit':    'edit'
    'click .destroy': 'destroy'

  tagName: "tr"  

  show : (e) -> 
    @followLink e

  edit : (e) -> 
    @followLink e

  destroy: (e) ->
    @model.destroy()
    @leave()
    return false

  render: ->
    $(@el).html(@template(@model.toJSON()))
    @
