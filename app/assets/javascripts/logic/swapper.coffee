@Swapper = 
  setView: (newView) ->
    @view.leave()  if @view?.leave
    @view = newView
    @view.render()
    
# extend Backbone.Router
_.extend Backbone.Router::, @Swapper