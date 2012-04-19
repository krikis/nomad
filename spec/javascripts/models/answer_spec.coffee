describe "Answer model", ->
  Answer = undefined
  beforeEach ->
    Answer = Nomad.Models.Answer
    
  it "has 'answer' for parameter root", -> 
    expect(Answer::paramRoot).toEqual 'answer'
    
  describe "defaults", ->
    answer = undefined
    beforeEach ->
      answer = new Answer()
    
    it "sets the 'patient_id' attribute to 'null' by default", ->
      expect(answer.get('patient_id')).toEqual null
      
    it "sets the 'values' atribute to an empty object by default", ->
      expect(answer.get('values')).toEqual {}
      
  
describe "the Answers collection", ->
  Answers = undefined
  beforeEach ->
    Answers = Nomad.Collections.Answers
    
  it "has the Answer model for model", ->
    expect(Answers::model).toEqual Nomad.Models.Answer
    
  it "lives in the '/answers' url", ->
    expect(Answers::url).toEqual '/answers'
    
  describe "localStorage", ->
    it "has a localStorage defined using the 'Answers' namespace", ->
      expect(Answers::localStorage.name).toEqual 'Answers'
      