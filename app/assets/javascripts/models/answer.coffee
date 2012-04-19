class Nomad.Models.Answer extends Backbone.Model
  paramRoot: 'answer'

  defaults:
    patient_id: null
    values: {}

class Nomad.Collections.Answers extends Backbone.Collection
  model: Nomad.Models.Answer
  url: '/answers'
  localStorage: new Backbone.LocalStorage("Answers")