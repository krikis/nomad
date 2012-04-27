Nomad.Views.Answers ||= {}

class Nomad.Views.Answers.IndexView extends Backbone.View
  
  className: 'answers'
    
  render: ->
    @collection.each(@addAnswer)
  
  addAnswer: (answer) =>
    @appendChild(new Nomad.Views.Answers.AnswerView(model: answer))
                