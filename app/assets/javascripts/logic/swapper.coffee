@Swapper = 
  setView: (newView) ->
    @view.leave()  if @view?.leave
    @view = newView
    @view.render()