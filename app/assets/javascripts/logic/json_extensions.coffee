unless JSON.dateReviver?
  JSON.dateReviver = (key, value) ->
    if _.isString value
      dateRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d*)?Z$/
      if dateRegex.test value
        value = new Date value
    value
    