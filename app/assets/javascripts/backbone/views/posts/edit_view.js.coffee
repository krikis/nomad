Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.EditView extends Backbone.View
  # template : JST["backbone/templates/posts/edit"]
  template: _.template($('#posts-edit').html())

  events :
    "click .index" : "index"
    "click .show"  : "index"
    "submit #edit-post" : "update"
    
  index : (e) -> 
    e.preventDefault()
    Backbone.history.navigate $(e.target).attr("href"), trigger: true    
    
  show : (e) -> 
    e.preventDefault()
    Backbone.history.navigate $(e.target).attr("href"), trigger: true

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
