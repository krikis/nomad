class Nomad.Collections.Answers extends Backbone.Collection
  model: Nomad.Models.Answer
  url: '/answers'
  localStorage: new Backbone.LocalStorage("Answers")
