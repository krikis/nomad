describe "CompositeView", ->
  beforeEach ->
    @view = new Backbone.View

  describe "#leave", ->
    it "unbinds all event bindings received", ->
      callbackStub = sinon.stub()
      @view.on "test", callbackStub, @model
      @view.trigger "test"
      expect(callbackStub).toHaveBeenCalled()
      callbackStub.reset()
      @view.leave()
      @view.trigger "test"
      expect(callbackStub).not.toHaveBeenCalled()

    it "calls the 'unbindFromAll' method", ->
      unbindStub = sinon.stub(@view, "unbindFromAll")
      @view.leave()
      expect(unbindStub).toHaveBeenCalledOnce()
      unbindStub.restore()

    it "removes itself from the page", ->
      @view.el.className = "test_view"
      setFixtures("<div class='fixture'></div>")
      $(".fixture").append @view.render().el
      expect($(".fixture")).toContain ".test_view"
      @view.leave()
      expect($(".fixture")).not.toContain ".test_view"
      
    describe "when it has children", ->      
      beforeEach -> 
        @view.children = _([])

      it "calls the _leaveChildren method", ->
        leaveChildrenStub = sinon.stub(@view, "_leaveChildren")
        @view.leave()
        expect(leaveChildrenStub).toHaveBeenCalled()
        leaveChildrenStub.restore()

      it "calls the _removeFromParent method", ->
        removeFromParentStub = sinon.stub(@view, "_removeFromParent")
        @view.leave()
        expect(removeFromParentStub).toHaveBeenCalled()
        removeFromParentStub.restore()
        
  describe "#_leaveChildren", ->



