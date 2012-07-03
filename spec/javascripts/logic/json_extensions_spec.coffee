describe 'JSON_extensions', ->
  
  describe '.dateReviver', ->
    it 'returns non-text values unchanged', ->
      parsed = JSON.parse JSON.stringify(
        number: 1234.5
      ), JSON.dateReviver
      expect(parsed.number).toEqual(1234.5)
      
    it 'returns text values unchanged', ->
      parsed = JSON.parse JSON.stringify(
        text: 'hello world'
      ), JSON.dateReviver
      expect(parsed.text).toEqual('hello world')
      
    it 'returns dates as dates', ->
      date = new Date
      parsed = JSON.parse JSON.stringify(
        date: date
      ), JSON.dateReviver
      expect(parsed.date).toEqual(date)
      