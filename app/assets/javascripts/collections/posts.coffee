class Nomad.Collections.PostsCollection extends Backbone.Collection
  initialize: ->
    new BackboneSync.FayeSubscriber(@,
      channel: "posts"
    )
  model: Nomad.Models.Post
  url: '/posts'
  localStorage: new Backbone.LocalStorage("PostsCollection")
