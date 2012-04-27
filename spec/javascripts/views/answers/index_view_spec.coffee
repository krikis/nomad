describe "IndexViewSpec", ->
  
  beforeEach ->
    @view = new Nomad.Views.Answers.IndexView
    
  describe "Instantiation", ->
    it "creates a div element", ->
      expect(@view.el.nodeName).toEqual("DIV")
      
    it "creates an element with class 'answers'", ->
      expect($(@view.el)).toHaveClass("answers")
      
  describe "Rendering", ->
    beforeEach ->
      @answerView = new Backbone.View
      @answerViewStub = sinon.stub(Nomad.Views.Answers, "AnswerView").
        returns @answerView
      @answer1 = new Backbone.Model id: 1  
      @answer2 = new Backbone.Model id: 2
      @answer3 = new Backbone.Model id: 3
      @view.collection = new Backbone.Collection [@answer1,
                                                  @answer2,
                                                  @answer3]
      @view.render()
      
    afterEach ->
      Nomad.Views.Answers.AnswerView.restore()
      
    it "creates an answer view for each answer in the collection", ->
      expect(@answerViewStub).toHaveBeenCalledThrice()
      expect(@answerViewStub).toHaveBeenCalledWith model: @answer1
      expect(@answerViewStub).toHaveBeenCalledWith model: @answer2
      expect(@answerViewStub).toHaveBeenCalledWith model: @answer3
      
      
      