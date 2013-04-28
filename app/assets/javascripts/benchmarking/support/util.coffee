@Util =
  # multipurpose randomizer utility function
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

  # generates object with propCount: random attributes
  randomObject: (options={})->
    object = {}
    propCount = options.propCount || @randomFrom(10, 30)
    for prop in [1..propCount]
      do (prop) =>
        object[@randomProp()] = @randomValue(options)
    object

  # generates random property key
  randomProp: ->
    @randomString
      stringSize: 5
      charSet: 'abcdefghijklmnopqrstuvwxyz'

  # generates attribute of random type
  randomValue: (options={})->
    options.typeOdds ||= [1, 1, 2, 4]
    values = [
      @randomBoolean,
      @randomNumber,
      @randomString,
      @loremIpsum
    ]
    @randomFrom(values, options.typeOdds).call(@, options)

  # generates random boolean
  randomBoolean: ->
    @randomFrom [true, false]

  # generates random numerical of given decimals:
  randomNumber: (options={})->
    decimals = options.decimals || @randomFrom(1, 5)
    numberSet = '0123456789'
    nonzeroSet = '123456789'
    randomNumbers = [@randomFrom(nonzeroSet)]
    while randomNumbers.length < decimals
      randomNumbers.push @randomFrom(numberSet)
    parseInt randomNumbers.join('')

  # generates random string of given stringSize: from charSet:
  randomString: (options={}) ->
    stringSize = options.stringSize || @randomFrom(5, 15)
    charSet = options.charSet || 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    randomString = []
    while randomString.length < stringSize
      randomString.push @randomFrom(charSet)
    randomString.join('')

  # generates random lorem ipsum of given textSize:
  loremIpsum: (options={}) ->
    textSize = options.textSize || @randomFrom(20, 100)
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

  # all lorem ipsum words
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

  # generates clone of object with random changes proportional to amountOfChange
  randomVersion: (object, options = {})->
    amountOfChange = options['change']
    unless amountOfChange > 0 and amountOfChange < 1
      amountOfChange = @randomFrom([0.3, 0.4, 0.5, 0.6, 0.7])
    version = _.deepClone object
    properties = _.properties(version)
    nrOfProperties = properties.length
    deleted = []
    changeOdds = options['changeOdds']
    if changeOdds
      [delPropCount, changePropCount, newPropCount] = changeOdds
    else
      delPropCount = @randomFrom([0.1, 0.2, 0.3])
      changePropCount = @randomFrom([0.5, 0.6, 0.7])
      newPropCount = @randomFrom([0.1, 0.2, 0.3])
    totalChange = delPropCount + changePropCount + newPropCount
    if totalChange > 0
      # normalize
      delPropCount = Math.round(nrOfProperties * amountOfChange * delPropCount / totalChange)
      for prop in [0...delPropCount]
        do =>
          if properties.length > 0
            property = @randomFrom(properties)
            deleted.push property
            delete version[property]
      # normalize
      changePropCount = _.max [1, Math.round(nrOfProperties * amountOfChange * changePropCount / totalChange)]
      for prop in [0...changePropCount]
        do =>
          if properties.length > 0
            property = @randomFrom(properties)
            original = version[property]
            if _.isNumber original
              version[property] += @randomNumber(decimals: 3)
            else if _.isBoolean original
              version[property] = not version[property]
            else if _.isString original
              if ' ' in original
                newText = @loremIpsumVersion version[property], amountOfChange
                while original is newText
                  newText = @loremIpsumVersion version[property], amountOfChange
                version[property] = newText
              else
                newString = @stringVersion version[property], amountOfChange
                while original is newString
                  newString = @stringVersion version[property], amountOfChange
                version[property] = newString
      # normalize
      newPropCount = Math.round(nrOfProperties * amountOfChange * newPropCount / totalChange)
      for prop in [0...newPropCount]
        do =>
          version[@randomProp()] = @randomValue()
    [version, deleted]

  # generates clone of string with random changes proportional to amountOfChange
  stringVersion: (string, amountOfChange) ->
    unless amountOfChange > 0 and amountOfChange < 1
      amountOfChange = @randomFrom([0.3, 0.4, 0.5, 0.6, 0.7])
    nrOfChars = string.length
    out = string.slice()
    delCharCount = @randomFrom([0.1, 0.2, 0.3])
    changeCharCount = @randomFrom([0.5, 0.6, 0.7])
    newCharCount = @randomFrom([0.1, 0.2, 0.3])
    totalChange = delCharCount + changeCharCount + newCharCount
    delCharCount = Math.round(nrOfChars * amountOfChange * delCharCount / totalChange)
    for char in [0...delCharCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index) + out.slice(index + 1)
    changeCharCount = _.max [1, Math.round(nrOfChars * amountOfChange * changeCharCount / totalChange)]
    for char in [0...changeCharCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index) + @randomString(stringSize: 1) + out.slice(index + 1)
    newCharCount = Math.round(nrOfChars * amountOfChange * newCharCount / totalChange)
    for char in [0...newCharCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index) + @randomString(stringSize: 1) + out.slice(index)
    out

  # generates clone of text with random changes proportional to amountOfChange
  loremIpsumVersion: (text, amountOfChange)->
    unless amountOfChange > 0 and amountOfChange < 1
      amountOfChange = @randomFrom([0.3, 0.4, 0.5, 0.6, 0.7])
    out = _.flatten _.map text.split('. '), (sentence)-> sentence.split(', ')
    nrOfParts = out.length
    delPartCount = @randomFrom([0.1, 0.2, 0.3])
    changePartCount = @randomFrom([0.5, 0.6, 0.7])
    newPartCount = @randomFrom([0.1, 0.2, 0.3])
    totalChange = delPartCount + changePartCount + newPartCount
    delPartCount = Math.round(nrOfParts * amountOfChange * delPartCount / totalChange)
    for part in [0...delPartCount]
      do =>
        index = @randomFrom([0...out.length])
        out = out.slice(0, index).concat out.slice(index + 1)
        out[index - 1] += '.' if _.isEmpty(out[index]) and not _.isEmpty(out[index - 1])
    changePartCount = _.max [1, Math.round(nrOfParts * amountOfChange * changePartCount / totalChange)]
    for part in [0...changePartCount]
      do =>
        index = @randomFrom([0...out.length])
        subsentence = @loremIpsum(textSize: @randomFrom(3, 7))
        unless /[A-Z]/.test(_.first(out[index]))
          subsentence = subsentence[0].toLowerCase() + subsentence.substring(1)
        unless _.isEmpty(out[index + 1])
          subsentence = subsentence.substring(0, subsentence.length - 1)
        out = out.slice(0, index).concat [subsentence].concat out.slice(index + 1)
    newPartCount = Math.round(nrOfParts * amountOfChange * newPartCount / totalChange)
    for part in [0...newPartCount]
      do =>
        index = @randomFrom([0..out.length])
        subsentence = @loremIpsum(textSize: @randomFrom(3, 7))
        if _.isEmpty(out[index])
          unless _.isEmpty(lastSubsentence = out[index - 1])
            out[index - 1] = lastSubsentence.substring(0, lastSubsentence.length - 1)
        else
          subsentence = subsentence.substring(0, subsentence.length - 1)
        out = out.slice(0, index).concat [subsentence].concat out.slice(index)
    _.each [0...out.length - 1], (index)->
      if /[A-Z]/.test(_.first(out[index + 1]))
        out[index] += '.'
      else
        out[index] += ','
    out.join(' ')

  # generates lorem ipsum text block of given dataSize
  # supported sizes are 70KB, 140KB, 210KB, 280KB, 560KB and 1120KB
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
      when 'data420KB'
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
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


