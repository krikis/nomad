describe "AnswersRouter", ->
  AnswersRouter = undefined
  beforeEach ->
    AnswersRouter = Nomad.Routers.AnswersRouter
    
  it "exists", ->
    expect(AnswersRouter).toBeDefined()
    
  