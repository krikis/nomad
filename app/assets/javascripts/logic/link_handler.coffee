@LinkHandler = 
  followLink: (event) ->
    event.preventDefault()
    Backbone.history.navigate $(event.target).attr("href"), trigger: true