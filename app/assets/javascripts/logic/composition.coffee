@Composition =
  leave: ->
    @unbind()
    @unbindFromAll()
    @remove()
    @_leaveChildren()
    @_removeFromParent()

  _leaveChildren: ->  
    @children ||= _([])
    @children.chain().clone().each (view) ->
      view.leave()  if view.leave

  _removeFromParent: ->
    @parent._removeChild @ if @parent

  _removeChild: (view) ->
    index = @children.indexOf(view)
    @children.splice index, 1

  appendChild: (view) ->
    @renderChild view
    $(@el).append view.el

  appendChildTo: (view, container) ->
    @renderChild view
    $(container).append view.el

  renderChildInto: (view, container) ->
    @renderChild view
    $(container).empty().append view.el

  renderChild: (view) ->
    view.render()
    @children ||= _([])
    @children.push view
    view.parent = @

# extend Backbone.View
_.extend Backbone.View::,   @Composition