Nomad.Views.Answers ||= {}

class Nomad.Views.Answers.AnswerView extends Backbone.View  
  template: JST["answers/answer"]
  
  render: ->
    $(@el).html @template(@model.toJSON())
    @