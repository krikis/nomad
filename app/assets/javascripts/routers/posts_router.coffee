class Nomad.Routers.PostsRouter extends Backbone.Router
  routes:
    "posts/new"      : "newPost"
    "posts/index"    : "index"
    "posts/:id/edit" : "edit"
    "posts/:id"      : "show"
    "posts.*"        : "index"

  initialize: (options) ->
    @posts = new Nomad.Collections.PostsCollection
    @posts.fetch()
    
  newPost: ->
    @setView(new Nomad.Views.Posts.NewView(collection: @posts))
    $("#posts").html(@view.render().el)

  index: ->
    @setView(new Nomad.Views.Posts.IndexView(posts: @posts))
    $("#posts").html(@view.render().el)

  show: (id) ->
    post = @posts.get(id)

    @setView(new Nomad.Views.Posts.ShowView(model: post))
    $("#posts").html(@view.render().el)

  edit: (id) ->
    post = @posts.get(id)

    @setView(new Nomad.Views.Posts.EditView(model: post))
    $("#posts").html(@view.render().el)
