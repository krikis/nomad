describe "Observer", ->
  describe "#bindTo", ->
    beforeEach ->
      @view = new Backbone.View
      @model = new Backbone.Model
      @onStub = sinon.stub(@model, "on")
      @callback = sinon.stub()
      @event = "test_event"

    afterEach ->
      @onStub.restore()

    it "binds an object's callback to a given source and event", ->
      @view.bindTo @model, @event, @callback
      expect(@onStub).toHaveBeenCalledWith @event, @callback, @view

    it "initializes the bindings field as a wrapped empty array
        should it be undefined", ->
      @view.bindings = undefined
      @view.bindTo @model, @event, @callback
      expect(@view.bindings).toBeDefined()
      expect(@view.bindings._wrapped).toBeDefined()
      expect(@view.bindings._wrapped.constructor.name).toEqual("Array")

    it "adds the source to the bindings array", ->
      @view.bindTo @model, @event, @callback
      expect(@view.bindings).toContain @model

  describe "#unbindFromAll", ->
    beforeEach ->
      @view = new Backbone.View
      @model = new Backbone.Model
      @callback = sinon.stub()
      @event = "test_event"
      @model.on @event, @callback, @view
      @view.bindings ||= _([])
      @view.bindings.push @model

    it "unbinds each source in bindings", ->
      @model.trigger @event
      expect(@callback).toHaveBeenCalled();
      @view.unbindFromAll()
      @callback.reset()
      @model.trigger @event
      expect(@callback).not.toHaveBeenCalled();
      
    it "empties the bindings list", ->
      expect(@view.bindings.size()).toBeGreaterThan 0
      @view.unbindFromAll()
      expect(@view.bindings.size()).toEqual 0
      

