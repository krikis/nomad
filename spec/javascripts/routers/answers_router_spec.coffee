describe "AnswersRouterSpec", ->
  
  beforeEach ->
    @currentPath = window.location.pathname
    @currentParameters = window.location.search
    @AnswersRouter = Nomad.Routers.AnswersRouter
    @router = new @AnswersRouter
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
    
    
    
  