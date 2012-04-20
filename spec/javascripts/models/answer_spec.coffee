describe "Answer", ->
  beforeEach ->
    @answer = new Nomad.Models.Answer
    @answer.collection = 
      url: "/collection"              # stub the model's collection url
    
  describe "defaults", ->    
    it "sets the 'patient_id' attribute to 'null' by default", ->
      expect(@answer.get('patient_id')).toEqual null
      
    it "sets the 'values' atribute to an empty object by default", ->
      expect(@answer.get('values')).toEqual {}
      
  describe "validations", ->
    beforeEach ->
      @validationSpy = sinon.spy()
      @answer.bind "error", @validationSpy
      
    it "does not save when the 'patient_id' attribute is empty", ->
      @answer.save
        patient_id: ''
      expect(@validationSpy).toHaveBeenCalledOnce()  
      expect(@validationSpy).
        toHaveBeenCalledWith(@answer,
                             "cannot have an empty patient id")
    
      