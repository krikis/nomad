describe "Answers", ->
  Answers = undefined
  beforeEach ->
    Answers = Nomad.Collections.Answers

  it "has the Answer model for model", ->
    expect(Answers::model).toEqual Nomad.Models.Answer

  it "lives in the '/answers' url", ->
    expect(Answers::url).toEqual '/answers'
    
  it "orders answers by created_at", ->
    

  describe "localStorage", ->
    it "has a localStorage defined using the 'Answers' namespace", ->
      expect(Answers::localStorage.name).toEqual 'Answers'
