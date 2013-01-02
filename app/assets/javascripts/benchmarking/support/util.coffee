@Util =
  benchmarkData: (dataSize)->
    switch dataSize
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
        dataSize
      
  randomObject: (options = {})->
    object = {}
    propCount = @randomFrom(10, 30)
    for prop in [1..propCount]
      do (prop) =>
        object[@randomProp()] = @randomValue(options)
    object
  
  randomProp: ->
    @randomString(5, 'abcdefghijklmnopqrstuvwxyz')
  
  randomVersion: (object, amountOfChange)->
    unless amountOfChange > 0 and amountOfChange < 1
      amountOfChange = @randomFrom([0.3, 0.4, 0.5, 0.6, 0.7])
    version = _.deepClone object
    properties = _.properties(version)
    nrOfProperties = properties.length
    deleted = []
    delPropCount = Math.floor(nrOfProperties * amountOfChange * @randomFrom([0.1, 0.2, 0.3]))
    for prop in [0...delPropCount]
      do =>
        if properties.length > 0
          property = @randomFrom(properties)
          deleted.push property
          delete version[property]
    changePropCount = Math.floor(nrOfProperties * amountOfChange * @randomFrom([0.5, 0.6, 0.7]))
    for prop in [0...changePropCount]
      do =>
        if properties.length > 0
          property = @randomFrom(properties)
          original = version[property]
          if _.isNumber original
            version[property] = @randomNumber()
          else if _.isBoolean original
            version[property] = @randomBoolean()
          else if _.isString original
            if ' ' in original
              version[property] = @loremIpsumVersion version[property], amountOfChange
            else
              version[property] = @stringVersion version[property], amountOfChange
    newPropCount = Math.floor(nrOfProperties * amountOfChange * @randomFrom([0.1, 0.2, 0.3]))
    for prop in [0...newPropCount]
      do =>
        version[@randomProp()] = @randomValue()
    [version, deleted]
    
  randomValue: (options = {})->
    options.typeOdds ||= [1, 1, 2, 4]
    values = [
      @randomBoolean,
      @randomNumber,
      @randomString,
      @loremIpsum
    ]
    @randomFrom(values, options.typeOdds).call(@)
      
  randomBoolean: ->
    @randomFrom [true, false]    
      
  randomNumber: (decimals) ->
    unless decimals?
      decimals = @randomFrom(1, 5)
    numberSet = '0123456789'
    nonzeroSet = '123456789'
    randomNumbers = [@randomFrom(nonzeroSet)]
    while randomNumbers.length < decimals
      randomNumbers.push @randomFrom(numberSet)
    parseInt randomNumbers.join('')

  randomString: (stringSize, charSet) ->
    unless stringSize?
      stringSize = @randomFrom(5, 15)
    charSet ||= 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    randomString = []
    while randomString.length < stringSize
      randomString.push @randomFrom(charSet)
    randomString.join('')

  stringVersion: (string, amountOfChange) ->
    unless amountOfChange > 0 and amountOfChange < 1
      amountOfChange = @randomFrom([0.3, 0.4, 0.5, 0.6, 0.7])
    nrOfChars = string.length
    out = string.slice()
    delCharCount = Math.floor(nrOfChars * amountOfChange * @randomFrom([0.1, 0.2, 0.3]))    
    for char in [0...delCharCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index) + out.slice(index + 1)
    changeCharCount = Math.floor(nrOfChars * amountOfChange * @randomFrom([0.5, 0.6, 0.7]))
    for char in [0...changeCharCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index) + @randomString(1) + out.slice(index + 1)
    newCharCount = Math.floor(nrOfChars * amountOfChange * @randomFrom([0.1, 0.2, 0.3]))
    for char in [0...newCharCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index) + @randomString(1) + out.slice(index)
    out

  randomFrom: ->
    # select random entry from array or string
    if _.isArray(arguments[0]) or _.isString(arguments[0])
      selectFrom = arguments[0]
      # select with predefined probability
      if _.isArray(arguments[1])
        frequencies = arguments[1]
        values = selectFrom.slice()
        selectFrom = []
        _.each values, (value, index)->
          frequency = parseInt(frequencies[index])
          if frequency > 0
            _.each [1..frequency], ->
              selectFrom.push value   
      index = Math.floor(Math.random() * selectFrom.length)
      selectFrom[index]
    # generate random float
    else if arguments.length == 1 and _.isNumber(arguments[0])
      Math.random() * arguments[0]
    # generate random integer within range
    else
      begin = arguments[0]
      end = arguments[1] + 1
      Math.floor(Math.random() * (end - begin)) + begin

  loremIpsum: (textSize) ->
    textSize ||= @randomFrom(20, 100)
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
  
  loremIpsumVersion: (text, amountOfChange)->
    unless amountOfChange > 0 and amountOfChange < 1
      amountOfChange = @randomFrom([0.3, 0.4, 0.5, 0.6, 0.7])
    out = _.flatten _.map text.split('. '), (sentence)-> sentence.split(', ')
    nrOfParts = out.length
    delPartCount = Math.floor(nrOfParts * amountOfChange * @randomFrom([0.1, 0.2, 0.3]))    
    for part in [0...delPartCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index).concat out.slice(index + 1)
        out[index] += '.' if _.isEmpty(out[index + 1])
    changePartCount = Math.ceil(nrOfParts * amountOfChange * @randomFrom([0.5, 0.6, 0.7]))
    for part in [0...changePartCount]
      do =>
        index = @randomFrom([0...out.length])
        subsentence = @loremIpsum(@randomFrom(3, 7))
        unless /[A-Z]/.test(_.first(out[index]))
          subsentence = subsentence[0].toLowerCase() + subsentence.substring(1)
        unless _.isEmpty(out[index + 1])
          subsentence = subsentence.substring(0, subsentence.length - 1)
        out = out.slice(0, index).concat [subsentence].concat out.slice(index + 1)
    newPartCount = Math.floor(nrOfParts * amountOfChange * @randomFrom([0.1, 0.2, 0.3]))
    for part in [0...newPartCount]
      do =>
        index = @randomFrom([0..out.length])
        subsentence = @loremIpsum(@randomFrom(3, 7))
        unless _.isEmpty(out[index])
          subsentence = subsentence.substring(0, subsentence.length - 1)
        out = out.slice(0, index).concat [subsentence].concat out.slice(index)
    _.each [0...out.length - 1], (index)->
      if /[A-Z]/.test(_.first(out[index + 1]))
        out[index] += '.'
      else
        out[index] += ','
    out.join(' ')

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
