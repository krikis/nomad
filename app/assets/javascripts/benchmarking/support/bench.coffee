class @Bench
  DEFAULT_NR_OF_RUNS: 10
  DEFAULT_TIMEOUT: 1000

  constructor: (options = {}) ->
    @suite    = options.suite
    @measure  = options.measure  || @suite?.measure
    @category = options.category || @uid()
    @series   = options.series   || @uid()
    @setup    = options.setup    || (next) -> next.call(@)
    @before   = options.before   || (next) -> next.call(@)
    @test     = options.test     || (next) -> next.call(@)
    @after    = options.after    || (next) -> next.call(@)
    @cleanup  = options.cleanup  || (next) -> next.call(@)
    @baseline = options.baseline || -> @start = new Date
    @record   = options.record   || -> new Date - @start
    @round    = true
    @round    = options.round    if options.round?
    @unit     = options.unit
    @unitLong = options.unitLong
    @runs     = options.runs     || @DEFAULT_NR_OF_RUNS
    @timeout  = options.timeout  || @DEFAULT_TIMEOUT
    @chart    = options.chart    if options.chart?
    @seeds    = options.seeds
    @initStats()
    @initChart()
    @saveStats()

  initStats: ->
    @key        = "#{@series}_#{@category}"
    @namespace  = @suite?.name || ""
    @stats      = JSON.parse(localStorage["system_#{@namespace}_#{@key}_stats"] || "[]")
    @[@measure] = JSON.parse(localStorage["system_#{@namespace}_#{@key}_#{@measure}"] || 0)
    @categories = @suite?.categories || []
    @allSeries  = @suite?.allSeries  || []

  initChart: ->
    unless @series in @allSeries
      @allSeries.push @series
      @chart?.addSeries
        name: @series
        data: []
    unless @category in @categories
      @categories.push @category
      @chart.xAxis[0].setCategories @categories if @chart?
    if @chart?
      seriesIndex = 0
      _.each @chart.series, (series) =>
        while series.data.length < @categories.length
          series.addPoint 0

  saveStats: ->
    localStorage["system_#{@namespace}_#{@key}_stats"] = JSON.stringify @stats
    localStorage["system_#{@namespace}_#{@key}_#{@measure}"] = JSON.stringify @[@measure]
    if @suite?
      @suite.categories = @categories
      @suite.allSeries  = @allSeries

  run: (options = {}) ->
    @next      = options.next
    @context   = options.context
    @chart     = options.chart   if options.chart?
    @benchData = options.data    || 'data70KB'
    @runs      = options.runs    if options.runs
    @timeout   = options.timeout if options.timeout
    @button    = options.button
    $(@button).attr('disabled': true) if @button?
    @total = 0
    @count = 0
    setTimeout (=>
      try
        @setup.call(@, @testLoop)
      catch error
        @handleError error
    ), 100

  testLoop: () ->
    setTimeout (=>
      try
        if @count < @runs and not @suite?.stopped() 
          @before.call(@, @testFunction)
          @count++
        else
          @cleanup.call(@, @stop)
      catch error
        @handleError error
    ), 100

  testFunction: ->
    setTimeout (=>
      try
        @baseline.call(@)
        @test.call(@, @afterFunction)
      catch error
        @handleError error
    ), 100

  afterFunction: ->
    @total += @record.call(@)
    setTimeout (=> 
      try
        @after.call(@, @testLoop)
      catch error
        @handleError error
    ), 100

  stop: ->
    setTimeout (=>
      @processResults()
      $(@button).attr('disabled': false) if @button?
      # return control to next bench if present
      @next?.call(@context)
    ), 100
    
  handleError: (error)->
    @suite?.finish(error)

  processResults: ->
    runtime = if @count > 0 then @total / @count else 0
    @initStats()
    @updateStats(runtime)
    @calculateMeasure()
    @redrawChart()
    @saveStats()

  updateStats: (runtime) ->  
    runtime = Math.round runtime if @round
    @suite?.log "[#{@category}] [#{@series}] [#{@count} runs]: #{runtime}"
    @stats.push runtime
      
  calculateMeasure: ->
    @previous = @[@measure] || 0
    switch @measure
      when 'mean'
        value = Math.mean(@stats)
      when 'median'
        value = Math.median(@stats)
    if @round
      @[@measure] = Math.round(value)
    else
      @[@measure] = value
      
  redrawChart: (options = {}) ->
    @chart = options.chart if options.chart?
    seriesIndex = _.indexOf(@allSeries, @series)
    categoryIndex = _.indexOf(@categories, @category)
    animation = options.animation || true
    @chart.series[seriesIndex].data[categoryIndex].update @[@measure], true, animation
    
  seed: (options = {}) ->
    @chart = options.chart if options.chart?
    @initStats()
    @stats = @seeds
    @calculateMeasure()
    @redrawChart
      animation:
        duration: 1000
        easing: 'swing'
    @saveStats()    

  benchmarkData: ->
    switch @benchData
      when 'data70KB'
        Benches['data70KB']
      when 'data140KB'
        Benches['data70KB'] +
        Benches['data70KB']
      when 'data210KB'
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB']
      when 'data280KB'
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB']
      when 'data560KB'
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB']
      when 'data1120KB'
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB']
      else
        @benchData
        
  randomObject: ->
    object = {}
    propCount = @randomFrom(10, 30)
    for prop in [1..propCount]
      do (prop) =>
        object[@randomProp()] = @randomValue()
    object
    
  randomProp: ->
    @randomString(5, 'abcdefghijklmnopqrstuvwxyz')
    
  randomVersion: (object, delPropCount, changePropCount, newPropCount, loremChange, stringChange) ->
    version = _.deepClone object
    delPropCount ||= @randomFrom(1, 3)
    for prop in [1..delPropCount]
      do (prop) =>
        delete version[@randomFrom(_.keys(version))]
    changePropCount ||= @randomFrom(4, 7)
    for prop in [1..changePropCount]
      do (prop) =>
        property = @randomFrom(_.keys(version))
        original = version[property]
        if _.isNumber original
          version[property] = @randomNumber()
        else if _.isBoolean original
          version[property] = @randomBoolean()
        else if _.isString original
          if ' ' in original
            version[property] = @loremIpsumVersion version[property], loremChange
          else
            version[property] = @stringVersion version[property], stringChange
    newPropCount ||= @randomFrom(1, 3)
    for prop in [1..newPropCount]
      do (prop) =>
        version[@randomProp()] = @randomValue()
    version
      
  randomValue: ->
    values = [
      @randomBoolean,
      @randomNumber,
      @randomString,
      @loremIpsum
    ]
    @randomFrom(values).call(@)
        
  randomBoolean: ->
    @randomFrom [true, false]    
        
  randomNumber: (decimals) ->
    decimals ||= @randomFrom(1, 5)
    numberSet = '0123456789'
    nonzeroSet = '123456789'
    randomNumbers = [@randomFrom(nonzeroSet)]
    while randomNumbers.length < decimals
      randomNumbers.push @randomFrom(numberSet)
    parseInt randomNumbers.join('')

  randomString: (stringSize, charSet) ->
    stringSize ||= @randomFrom(5, 15)
    charSet ||= 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    randomString = []
    while randomString.length < stringSize
      randomString.push @randomFrom(charSet)
    randomString.join('')

  stringVersion: (string, change = 5) ->
    begin = @randomFrom(0, string.length)
    end = Math.min(begin + @randomFrom(0, change), string.length)
    prefix = string.substring(0, begin)
    postfix = string.substring(end)
    infix = @randomString @randomFrom(0, change)
    prefix + infix + postfix

  randomFrom: ->
    # select random entry from array or string
    if _.isArray(arguments[0]) or _.isString(arguments[0])
      index = Math.floor(Math.random() * arguments[0].length)
      arguments[0][index]
    # generate random float
    else if arguments.length == 1 and _.isNumber(arguments[0])
      Math.random() * arguments[0]
    # generate random integer within range
    else
      begin = arguments[0]
      end = arguments[1] + 1
      Math.floor(Math.random() * (end - begin)) + begin

  loremIpsum: (textSize) ->
    textSize ||= @randomFrom(15, 100)
    minSentence = 5
    maxSentence = 15
    minSubSentence = 3
    maxSubSentence = 7
    out = []
    sentence = 0
    sentLength = undefined
    subSentence = 0
    subSentLength = undefined
    for number in [1..textSize]
      do (number) =>
        word = @randomFrom @loremIpsumWordBank
        sentence++
        subSentence++
        if sentence == 1
          word = word[0].toUpperCase() + word.substring(1)
          sentLength = @randomFrom(minSentence, maxSentence)
        if subSentence == 1
          subSentLength = @randomFrom(minSubSentence, maxSubSentence)
        if number == textSize or 
           (sentence == sentLength and 
            textSize - number >= minSentence)
          word += '.'
          sentence = 0
          subSentence = 0
        else if subSentence == subSentLength and 
                sentLength - sentence >= minSubSentence
          word += ','
          subSentence = 0
        out.push word
    out.join(' ')
    
  loremIpsumVersion: (text, change = 15) ->
    out = text.split(' ')
    begin = @randomFrom(0, out.length)
    end = Math.min(begin + @randomFrom(0, change), out.length)
    first = out.slice(0, begin).join(' ')
    last = out.slice(end).join(' ')
    middle = @loremIpsum @randomFrom(0, change)
    unless _.isEmpty middle
      unless (_.last(first) == '.') or _.isEmpty(first)
        middle = middle[0].toLowerCase() + middle.substring(1)
      unless /[A-Z]/.test(_.first(last)) or _.isEmpty(last)
        middle = middle.substring(0, middle.length - 1)
    [first, middle, last].join(' ')

  loremIpsumWordBank: [
    "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipisicing",
    "elit", "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore",
    "et", "dolore", "magna", "aliqua", "enim", "ad", "minim", "veniam",
    "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut",
    "aliquip", "ex", "ea", "commodo", "consequat", "duis", "aute", "irure",
    "dolor", "in", "reprehenderit", "in", "voluptate", "velit", "esse",
    "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "excepteur",
    "sint", "occaecat", "cupidatat", "non", "proident", "sunt", "in",
    "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est",
    "laborum", "sed", "ut", "perspiciatis", "unde", "omnis", "iste",
    "natus", "error", "sit", "voluptatem", "accusantium", "doloremque",
    "laudantium", "totam", "rem", "aperiam", "eaque", "ipsa", "quae",
    "ab", "illo", "inventore", "veritatis", "et", "quasi", "architecto",
    "beatae", "vitae", "dicta", "sunt", "explicabo", "nemo", "enim",
    "ipsam", "voluptatem", "quia", "voluptas", "sit", "aspernatur", "aut",
    "odit", "aut", "fugit", "sed", "quia", "consequuntur", "magni",
    "dolores", "eos", "qui", "ratione", "voluptatem", "sequi", "nesciunt",
    "neque", "porro", "quisquam", "est", "qui", "dolorem", "ipsum", "quia",
    "dolor", "sit", "amet", "consectetur", "adipisci", "velit", "sed",
    "quia", "non", "numquam", "eius", "modi", "tempora", "incidunt", "ut",
    "labore", "et", "dolore", "magnam", "aliquam", "quaerat", "voluptatem",
    "ut", "enim", "ad", "minima", "veniam", "quis", "nostrum",
    "exercitationem", "ullam", "corporis", "suscipit", "laboriosam", "nisi",
    "ut", "aliquid", "ex", "ea", "commodi", "consequatur", "quis", "autem",
    "vel", "eum", "iure", "reprehenderit", "qui", "in", "ea", "voluptate",
    "velit", "esse", "quam", "nihil", "molestiae", "consequatur", "vel",
    "illum", "qui", "dolorem", "eum", "fugiat", "quo", "voluptas", "nulla",
    "pariatur", "at", "vero", "eos", "et", "accusamus", "et", "iusto",
    "odio", "dignissimos", "ducimus", "qui", "blanditiis", "praesentium",
    "voluptatum", "deleniti", "atque", "corrupti", "quos", "dolores", "et",
    "quas", "molestias", "excepturi", "sint", "obcaecati", "cupiditate",
    "non", "provident", "similique", "sunt", "in", "culpa", "qui",
    "officia", "deserunt", "mollitia", "animi", "id", "est", "laborum",
    "et", "dolorum", "fuga", "harum", "quidem", "rerum", "facilis", "est",
    "et", "expedita", "distinctio", "nam", "libero", "tempore", "cum",
    "soluta", "nobis", "est", "eligendi", "optio", "cumque", "nihil",
    "impedit", "quo", "minus", "id", "quod", "maxime", "placeat",
    "facere", "possimus", "omnis", "voluptas", "assumenda", "est",
    "omnis", "dolor", "repellendus", "temporibus", "autem", "quibusdam",
    "aut", "officiis", "debitis", "aut", "rerum", "necessitatibus", "saepe",
    "eveniet", "ut", "et", "voluptates", "repudiandae", "sint", "molestiae",
    "non", "recusandae", "itaque", "earum", "rerum", "hic", "tenetur", "a",
    "sapiente", "delectus", "aut", "reiciendis", "voluptatibus", "maiores",
    "alias", "consequatur", "aut", "perferendis", "doloribus", "asperiores",
    "repellat"
  ]

  TIMEOUT_INCREMENT: 10

  waitsFor: (check, message, callback) ->
    @_waitFor(check, callback, message, 0)

  _waitFor: (check, callback, message, total) ->
    if check.apply(@)
      callback.apply(@) if _.isFunction(callback)
    else if total >= @timeout
      @suite?.log "Timed out afer #{total} msec waiting for #{message}!"
      # gracefully restart benchmark
      @suite?.runBench()
      return
    else
      total += @TIMEOUT_INCREMENT
      setTimeout (=>
        try
          @_waitFor.apply(@, [check, callback, message, total])
        catch error
          @handleError error          
      ), @TIMEOUT_INCREMENT

  # Generate four random hex digits.
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

  # Generate a pseudo-GUID by concatenating random hexadecimal.
  uid: ->
    S4() + S4()

  numerical: (a, b) ->
    a - b


