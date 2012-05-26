class Nomad.Collections.Answers extends Backbone.Collection
  model: Nomad.Models.Answer
  comparator: (answer)->
    answer.get('created_at')
