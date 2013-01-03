Benches = @Benches ||= {}

Benches.setupStructRebase1 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase1 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  @answer.set Benches.fixedAnswerV1u1()
  @dummy = new @Answer Benches.fixedAnswerV2()
  next.call @

Benches.structRebase1 = (next) ->
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