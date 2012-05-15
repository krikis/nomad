class Nomad.Collections.PostsCollection extends Backbone.Collection
  initialize: ->
    @channel = 'posts'
    @fayeClient = new BackboneSync.FayeClient(@,
      channel: posts
    )
  model: Nomad.Models.Post
  url: '/posts'
  localStorage: new Backbone.LocalStorage("PostsCollection")
