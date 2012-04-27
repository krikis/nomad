class Nomad.Routers.AnswersRouter extends Backbone.Router
  
  routes:
    "answers/index": "index"
    "answers/new":   "new"
    "answers*":      "index"
    
  index: ->
    @answers = new Nomad.Collections.Answers
    @setView new Nomad.Views.Answers.IndexView
                   answers: @answers
    @answers.fetch()
    
  new: ->
    
  