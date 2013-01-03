Benches = @Benches ||= {}

Benches.setupStructRebase6 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase6 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  @answer.set Benches.fixedAnswerV1u1()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.set Benches.fixedAnswerV1u3()
  @answer.set Benches.fixedAnswerV1u4()
  @answer.set Benches.fixedAnswerV1u5()
  @answer.set Benches.fixedAnswerV1u6()
  @dummy = new @Answer Benches.fixedAnswerV2()
  next.call @

Benches.structRebase6 = (next) ->
  # resolve the conflicts
  try
    @success = @answer._applyPatchesTo @dummy
  catch error
    if error.name == 'SyntaxError'
      @suite?.log "JSON format broken!"
    else
      @suite?.log error.message
      @suite?.log error.stack
    @success = false
  finally
    next.call @