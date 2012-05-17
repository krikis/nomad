class Nomad.Collections.PostsCollection extends Backbone.Collection
  model: Nomad.Models.Post
  url: '/posts'
  localStorage: new Backbone.LocalStorage("PostsCollection")
