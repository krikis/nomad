Benches = @Benches ||= {}

Benches.setupStruct = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
  @Answer = Answer 

Benches.beforeStruct = (next) ->
  @answer = new Answer

Benches.struct = (next) ->

Benches.afterStruct = (next) ->

Benches.cleanupStruct = (next) ->