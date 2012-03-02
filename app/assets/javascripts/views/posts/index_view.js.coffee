Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.IndexView extends Backbone.View
  template: JST["posts/index"]
  # template: _.template($('#posts-index').html())
  
  events:
    'click .new':     'new'

  initialize: () ->
    @options.posts.bind('reset', @addAll)
  
  new: (e) ->
    e.preventDefault()
    Backbone.history.navigate $(e.target).attr("href"), trigger: true

  addAll: () =>
    @options.posts.each(@addOne)

  addOne: (post) =>
    view = new Nomad.Views.Posts.PostView({model : post})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(posts: @options.posts.toJSON() ))
    @addAll()

    return this
