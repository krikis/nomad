describe "LinkHandler", ->
  beforeEach ->
    @view = new Backbone.View
    @event = {}
    @event.preventDefault = sinon.stub()
    @event.target = "<a href='some_url'></a>"
    @navigateStub = sinon.stub()
    historyStub = {navigate: @navigateStub}
    Backbone.history = historyStub

  afterEach ->
    delete Backbone.history

  describe "#followLink", ->
    it "prevents browser default link handling", ->
      @view.followLink @event
      expect(@event.preventDefault).toHaveBeenCalled()

    it "calls Backbone.history.navigate with the event target
        href and trigger set to true", ->
      @view.followLink @event
      expect(@navigateStub).
        toHaveBeenCalledWith "some_url", trigger: true