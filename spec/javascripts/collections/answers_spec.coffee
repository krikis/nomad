describe "AnswersSpec", ->
  beforeEach ->
    fayeClient = {}
    fayeClient.subscribe = ->
    fayeClient.publish = ->
    @subscribeStub = sinon.stub(fayeClient, 'subscribe')
    @publishStub = sinon.stub(fayeClient, 'publish')
    @clientConstructorStub = sinon.stub(Faye, 'Client')
    @clientConstructorStub.returns fayeClient
    Answers = Nomad.Collections.Answers
    @answers = new Answers

  afterEach ->
    @clientConstructorStub.restore()
    @answers._cleanup()
    # remove stub from window.client
    delete window.client

  it "has the Answer model for model", ->
    expect(@answers.model).toEqual Nomad.Models.Answer

  it "lives in the '/answers' url", ->
    expect(@answers.url).toEqual '/answers'
    
  it "orders answers by created_at", ->
    answer1 = new Backbone.Model
      created_at: new Date(2012, 4, 22, 20, 10, 30)
    answer2 = new Backbone.Model
      created_at: new Date(2012, 4, 22, 19, 10, 30)
    answer3 = new Backbone.Model
      created_at: new Date(2012, 4, 22, 18, 10, 30)
    @answers.add [answer1, answer2, answer3]
    expect(@answers.at(0)).toBe answer3
    expect(@answers.at(1)).toBe answer2
    expect(@answers.at(2)).toBe answer1
    
  describe "when it fetches models", ->
    beforeEach -> 
      @server = sinon.fakeServer.create()
      
    afterEach ->
      @server.restore()
      
    it "makes no server request", ->
      @answers.fetch()
      expect(@server.requests.length).toEqual 0

  describe "localStorage", ->
    it "has a localStorage defined using the 'Answers' namespace", ->
      expect(@answers.localStorage.name).toEqual 'Answer'
      
