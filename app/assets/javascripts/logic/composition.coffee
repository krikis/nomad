@Composition =
  leave: ->
    @unbind()
    @unbindFromAll()
    @remove()
    if @children?
      @_leaveChildren()
      @_removeFromParent()

  appendChild: (view) ->
    @renderChild view
    $(@el).append view.el

  renderChildInto: (view, container) ->
    @renderChild view
    $(container).empty().append view.el

  renderChild: (view) ->
    view.render()
    @children ||= _([])
    @children.push view
    view.parent = this

  _leaveChildren: ->  
    @children.chain().clone().each (view) ->
      view.leave()  if view.leave

  _removeFromParent: ->
    @parent._removeChild this  if @parent

  _removeChild: (view) ->  
    index = @children.indexOf(view)
    @children.splice index, 1