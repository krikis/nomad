describe 'Nomad', ->
  describe '.clientId', ->
    it 'is set to window.clientId', ->
      expect(Nomad.clientId).toEqual window.clientId
