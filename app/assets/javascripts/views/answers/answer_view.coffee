Nomad.Views.Answers ||= {}

class Nomad.Views.Answers.AnswerView extends Backbone.View  
  template: JST["answers/answer"]
  
  events:
    "click .id": "hide"
    
  hide: ->
    @$(".patient_id").fadeOut(500)
  
  render: ->
    $(@el).html @template(@model.toJSON())
    @