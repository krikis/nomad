Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.EditView extends Backbone.View
  template : JST["posts/edit"]

  events :
    "click .index" : "index"
    "click .show"  : "index"
    "submit #edit-post" : "update"

  index : (e) ->  
    @followLink e

  show : (e) ->
    @followLink e

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (post) =>
        @model = post
        Backbone.history.navigate "posts/#{@model.id}", trigger: true
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
