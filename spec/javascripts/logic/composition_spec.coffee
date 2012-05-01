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
    beforeEach ->
      @child = new Backbone.View
      @leaveStub = sinon.stub(@child, "leave")
      @view.children = _([@child])

    afterEach ->
      @leaveStub.restore()
      
    it "initializes the children field as a wrapped empty array should it be undefined", ->
      @view.children = undefined
      @view._leaveChildren()
      expect(@view.children).toBeDefined()
      expect(@view.children._wrapped).toBeDefined()
      expect(@view.children._wrapped.constructor.name).toEqual("Array")

    it "calls the leave method on each child", ->
      @view._leaveChildren()
      expect(@leaveStub).toHaveBeenCalled()

  describe "#_removeFromParent", ->
    beforeEach ->
      @parent = new Backbone.View
      @removeChildStub = sinon.stub(@parent, "_removeChild")
      @view.parent = @parent

    afterEach ->
      @removeChildStub.restore()

    it "calls the _removeChild method on the view's parent", ->
      @view._removeFromParent()
      expect(@removeChildStub).toHaveBeenCalledWith @view

  describe "#_removeChild", ->
    beforeEach ->
      @child1 = new Backbone.View
      @child2 = new Backbone.View
      @child3 = new Backbone.View
      @view.children = _([@child1, @child2, @child3])

    it "removes the child from the children list", ->
      @view._removeChild @child2
      expect(@view.children.size()).toEqual 2
      expect(@view.children).toContain @child1
      expect(@view.children).toContain @child3
      
  describe "#appendChild", ->
    beforeEach ->
      @child = new Backbone.View
    
    it "calls the renderChild method", ->
      renderChildStub = sinon.stub(@view, "renderChild")
      @view.appendChild @child
      expect(renderChildStub).toHaveBeenCalledWith @child
      renderChildStub.restore()
      
    it "appends the child's element to the views element", ->
      @child.el.className = "child"
      @view.appendChild @child
      expect($(@view.el)).toContain ".child"
      
  describe "#appendChildTo", ->
    beforeEach ->
      @child = new Backbone.View
    
    it "calls the renderChild method", ->
      renderChildStub = sinon.stub(@view, "renderChild")
      @view.appendChildTo @child, @view.el
      expect(renderChildStub).toHaveBeenCalledWith @child
      renderChildStub.restore()
      
    it "appends the child's element to the given container", ->
      container = $("<div class='container'></div>")
      @child.el.className = "child"
      @view.appendChildTo @child, container
      expect(container).toContain ".child"
      
  describe "#renderChildInto", ->
    beforeEach ->
      @child = new Backbone.View
    
    it "calls the renderChild method", ->
      renderChildStub = sinon.stub(@view, "renderChild")
      @view.renderChildInto @child, @view.el
      expect(renderChildStub).toHaveBeenCalledWith @child
      renderChildStub.restore()
    
    it "renders the child into the container after emptying it", ->
      container = $("<div class='container'><div class='some_content'></div></div>")
      @child.el.className = "child"
      @view.renderChildInto @child, container
      expect(container).toContain ".child"
      expect(container).not.toContain ".some_content"
      
  describe "#renderChild", ->
    beforeEach ->
      @child = new Backbone.View
    
    it "calls the render method on the child view", ->
      renderStub = sinon.stub(@child, "render")
      @view.renderChild @child
      expect(renderStub).toHaveBeenCalled()
      renderStub.restore()
      
    it "initializes the children field as a wrapped empty array should it be undefined", ->
      @view.children = undefined
      @view.renderChild @child
      expect(@view.children).toBeDefined()
      expect(@view.children._wrapped).toBeDefined()
      expect(@view.children._wrapped.constructor.name).toEqual("Array")
      
    it "adds the view to the children list", ->  
      @view.renderChild @child
      expect(@view.children).toContain @child
      
    it "sets the child's parent field to the view", ->
      @view.renderChild @child
      expect(@child.parent).toEqual @view
      
      
      
    
      






























