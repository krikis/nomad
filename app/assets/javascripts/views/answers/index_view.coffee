Nomad.Views.Answers ||= {}

class Nomad.Views.Answers.IndexView extends Backbone.View
  template: JST["answers/index"]
  
  className: 'answers'
    
  render: ->
    $(@el).html @template()
    @collection.each(@addAnswer)
    @
  
  addAnswer: (answer) =>
    @appendChildTo(
      new Nomad.Views.Answers.AnswerView(model: answer),
      @el
    )
                