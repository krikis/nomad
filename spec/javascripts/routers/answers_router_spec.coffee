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
  
  describe "#index", ->
    
    it "fires the index route with a blank hash", ->
      @router.bind "route:index", @routeSpy
      @router.navigate "", true
      expect(@routeSpy).toHaveBeenCalledOnce()
      expect(@routeSpy).toHaveBeenCalledWith()
      @router.unbind()
    
    it "calls the index method", ->
      sinon.spy(@router, "index")
      @router.navigate "", true
      expect(@router.index.calledOnce)
      expect(@router.index.calledWith())
      @router.index.restore()
    
  it "fires the new route providing the id", ->
    @router.bind "route:new", @routeSpy
    @router.navigate "new/1", true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith("1")
    @router.unbind()
    
    
    
  