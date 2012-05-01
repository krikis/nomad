describe "AnswerViewSpec", ->
  beforeEach ->
    @model = new Backbone.Model(Factory.build "answer")
    @view = new Nomad.Views.Answers.AnswerView
      model: @model
    setFixtures "<div class='fixture'></div>"

  describe "rendering", ->
    it "returns the view object for chaining", ->
      expect(@view.render()).toEqual @view

  describe "template", ->

    it "contains the model id", ->
      $(".fixture").append @view.render().el
      expect($(".fixture")).toHaveText new RegExp(@model.get("id"))

    describe "when the answer contains no values", ->
      beforeEach ->
        @model.set values: {}
        $(".fixture").append @view.render().el

      it "notifies about no values being present", ->
        expect($(".fixture")).toHaveText /There are no answers/

    describe "when values are present", ->
      beforeEach ->
        $(".fixture").append @view.render().el

      it "lists the values", ->
        expect($(".fixture")).toHaveText new RegExp(@model.get("values").v_1)

    describe "when the id paragraph is clicked", ->
      beforeEach ->
        @clock = sinon.useFakeTimers()
        $(".fixture").append @view.render().el
        $(".fixture .id").trigger('click')

      afterEach ->
        @clock.restore()

      it "hides the patient_id paragraph", ->
        @clock.tick 600
        expect($('.fixture .patient_id')).not.toBeVisible()

