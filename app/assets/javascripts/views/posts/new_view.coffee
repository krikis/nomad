Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.NewView extends Backbone.View
  template: JST["posts/new"]

  events:
    "click .index" : "index"
    "submit #new-post": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @bindTo @model, "change:errors", () ->
      @render()

  index : (e) -> 
    @followLink e

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (post) =>
        @model = post
        Backbone.history.navigate "posts/#{@model.id}", trigger: true

      error: (post, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
