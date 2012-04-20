describe "Answer", ->
  beforeEach ->
    @answer = new Nomad.Models.Answer()
    @answer.collection = 
      url: "/collection"              # stub the model's collection url
    
  describe "defaults", ->    
    it "sets the 'patient_id' attribute to 'null' by default", ->
      expect(@answer.get('patient_id')).toEqual null
      
    it "sets the 'values' attribute to an empty object by default", ->
      expect(@answer.get('values')).toEqual {}
    
  describe "when instantiating a model", ->  
    it "sets the 'created_at' attribute to the current time", ->
      date = new Date(2012, 4, 15, 15, 25, 36)
      clock = sinon.useFakeTimers(date.getTime())
      @answer.save(patient_id: "patient_id")
      clock.restore()
      expect(@answer.get('created_at').getTime()).toEqual(date.getTime())
      
    it "retains the 'created_at' timestamp once it is created", ->
      date1 = new Date(2012, 4, 15, 15, 25, 36)
      clock = sinon.useFakeTimers(date1.getTime())
      @answer.save(patient_id: "patient_id")
      clock.restore()
      date2 = new Date(2012, 4, 15, 15, 25, 36)
      clock = sinon.useFakeTimers(date2.getTime())
      @answer.save(patient_id: "patient_id")
      clock.restore()
      expect(@answer.get('created_at').getTime()).toEqual(date1.getTime())
      
    it "updates the 'updated_at' timestamp every time it is saved", ->
      date1 = new Date(2012, 4, 15, 15, 25, 36)
      clock = sinon.useFakeTimers(date1.getTime())
      @answer.save(patient_id: "patient_id")
      clock.restore()
      date2 = new Date(2012, 4, 15, 15, 25, 36)
      clock = sinon.useFakeTimers(date2.getTime())
      @answer.save(patient_id: "patient_id")
      clock.restore()
      expect(@answer.get('updated_at').getTime()).toEqual(date2.getTime())
      
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
    
      