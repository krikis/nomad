describe "Answer", ->
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
      