Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.IndexView extends Backbone.View
  template: JST["posts/index"]

  events:
    'click .new':     'new'

  initialize: () ->
    @options.posts.bind 'add', @render, @

  new: (e) ->
    @followLink e

  addOne: (post) =>
    @appendChildTo(
      new Nomad.Views.Posts.PostView({model : post}), 
      @$("tbody")
    )

  render: =>
    $(@el).html @template()
    @options.posts.each(@addOne)

    return this
