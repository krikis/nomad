Nomad.Views.Posts ||= {}

class Nomad.Views.Posts.IndexView extends Backbone.View
  template: JST["posts/index"]

  events:
    'click .new':     'new'
    'click .show':    'show'
    'click .edit':    'edit'
    'click .destroy': 'destroy'

  initialize: () ->
    @options.posts.bind('reset', @addAll)

  new: (e) ->
    e.preventDefault()
    Backbone.history.navigate $(e.target).attr("href"), trigger: true

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

  addAll: () =>
    @options.posts.each(@addOne)

  addOne: (post) =>
    view = new Nomad.Views.Posts.PostView({model : post})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(posts: @options.posts.toJSON() ))
    @addAll()

    return this
