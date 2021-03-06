describe "AnswersRouterSpec", ->
  
  beforeEach ->
    fayeClient = 
      publish: ->
      subscribe: ->
    @clientConstructorStub = sinon.stub(Faye, 'Client', -> fayeClient)
    @AnswersRouter = Nomad.Routers.AnswersRouter
    @router = new @AnswersRouter

  afterEach ->
    @clientConstructorStub.restore()
    # remove stub from window.client
    delete window.client
  
  describe "routes", ->  
    beforeEach ->
      @currentPath = window.location.pathname
      @currentParameters = window.location.search
      @routeSpy = sinon.spy()
      try
        Backbone.history.start
          silent: true
          pushState: true
      @router.navigate "someplace"
    
    afterEach ->
      @router.navigate @currentPath + @currentParameters
    
    it "exists", ->
      expect(@AnswersRouter).toBeDefined()
  
    describe "answers/index", ->    
      it "fires the index route with a blank hash", ->
        @router.bind "route:index", @routeSpy
        @router.navigate "answers/index", true
        expect(@routeSpy).toHaveBeenCalledOnce()
        expect(@routeSpy).toHaveBeenCalledWith()
        @router.unbind()
    
      it "calls the index method", ->
        sinon.spy @AnswersRouter::, "index"
        router = new @AnswersRouter
        router.navigate "answers/index", true
        expect(router.index).toHaveBeenCalledOnce()
        expect(router.index).toHaveBeenCalledWith()
        router.index.restore()
    
    describe "answers/new", ->
      it "fires the new route", ->
        @router.bind "route:new", @routeSpy
        @router.navigate "answers/new", true
        expect(@routeSpy).toHaveBeenCalledOnce()
        expect(@routeSpy).toHaveBeenCalledWith()
        @router.unbind()
      
      it "calls the new method", ->
        sinon.spy @AnswersRouter::, "new"
        router = new @AnswersRouter
        router.navigate "answers/new", true
        expect(router.new).toHaveBeenCalledOnce()
        expect(router.new).toHaveBeenCalledWith()
        router.new.restore()
    
  describe "handlers", ->
    beforeEach ->
      @collection = new Backbone.Collection([], modelName: 'TestModel')
      @fetchStub = sinon.stub(@collection, "fetch").returns null
      @answerListViewStub = sinon.stub(Nomad.Views.Answers, "IndexView").
        returns new Backbone.View
      @answersCollectionStub = sinon.
        stub(Nomad.Collections, "Answers").
        returns @collection
      
    afterEach ->
      @fetchStub.restore()
      @answerListViewStub.restore()
      @answersCollectionStub.restore()
      
    describe "index handler", ->
      describe "when no list exists", ->
        beforeEach -> 
          @router.index()
          
        it "creates an Answer list collection", ->
          expect(@answersCollectionStub).toHaveBeenCalledOnce()
          expect(@answerListViewStub).toHaveBeenCalledWith
            collection: @collection
            
        it "fetches the Answer list from storage", ->
          expect(@fetchStub).toHaveBeenCalledOnce()
          expect(@fetchStub).toHaveBeenCalledWith()
    
  