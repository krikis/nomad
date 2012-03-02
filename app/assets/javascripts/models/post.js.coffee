class Nomad.Models.Post extends Backbone.Model
  paramRoot: 'post'

  defaults:
    title: null
    content: null

class Nomad.Collections.PostsCollection extends Backbone.Collection
  model: Nomad.Models.Post
  url: '/posts'
