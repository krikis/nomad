describe "Swapper", ->
  describe "#setView", ->
    beforeEach ->
      @router  = new Backbone.Router
      @oldView = new Backbone.View
      @newView = new Backbone.View
      @router.view = @oldView
      @leaveStub = sinon.stub(@oldView, "leave")
      @renderStub = sinon.stub(@newView, "render")
      @router.setView @newView
      
    afterEach ->
      @leaveStub.restore()
      @renderStub.restore()
      
    it "makes the old view leave", ->
      expect(@leaveStub).toHaveBeenCalled()
      
    it "sets the router view to the new view", ->
      expect(@router.view).toEqual @newView
      
    it "renders the new view", ->
      expect(@renderStub).toHaveBeenCalled()