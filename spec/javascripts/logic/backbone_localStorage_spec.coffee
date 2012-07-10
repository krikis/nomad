describe 'Bacbone.LocalStorage', ->
  beforeEach ->
    fayeClient =
      publish: ->
      subscribe: ->
    @clientConstructorStub = sinon.stub(Faye, 'Client', -> fayeClient)

  afterEach ->
    @clientConstructorStub.restore()
    # remove stub from window.client
    delete window.client

  describe 'localStorage on collections', ->

    class TestCollection extends Backbone.Collection
    collection = undefined

    beforeEach ->
      TestCollection::localStorage = new Backbone.LocalStorage('TestCollection')
      collection = new TestCollection([], modelName: 'TestModel')

    afterEach ->
      collection._cleanup()

    it 'should be empty initially', ->
      expect(collection.length).toEqual 0 # 'empty initially'
      collection.fetch()
      expect(collection.length).toEqual 0 # 'empty read'

    it 'should create item', ->
      collection.create Factory.build('post')
      expect(collection.length).toEqual 1 # 'one item added'
      expect(collection.first().get('title')).toEqual 'The Tempest' # 'title was read'
      expect(collection.first().get('author')).toEqual 'Bill Shakespeare' # 'author was read'
      expect(collection.first().get('length')).toEqual 123 # 'length was read'

    it 'should discard unsaved changes on fetch', ->
      collection.create Factory.build('post')
      collection.first().set title: 'Wombat\'s Fun Adventure'
      expect(collection.first().get('title')).toEqual 'Wombat\'s Fun Adventure' # 'title changed, but not saved'
      collection.fetch()
      expect(collection.first().get('title')).toEqual 'The Tempest' # 'title was read'

    it 'should persist changes', ->
      collection.create Factory.build('post')
      expect(collection.first().get('author')).toEqual 'Bill Shakespeare' # 'author was read'
      collection.first().save author: 'William Shakespeare'
      collection.fetch()
      expect(collection.first().get('author')).toEqual 'William Shakespeare' # 'verify author update'

    it 'should allow to change id', ->
      collection.create Factory.build('post')
      collection.first().save
        id: '1-the-tempest'
        author: 'William Shakespeare'

      expect(collection.first().get('id')).toEqual '1-the-tempest' # 'verify ID update'
      expect(collection.first().get('title')).toEqual 'The Tempest' # 'verify title is still there'
      expect(collection.first().get('author')).toEqual 'William Shakespeare' # 'verify author update'
      expect(collection.first().get('length')).toEqual 123 # 'verify length is still there'
      collection.fetch()
      expect(collection.length).toEqual 2 # 'should not auto remove first object when changing ID'

    it 'should remove from collection', ->
      _(23).times (index) ->
        collection.create id: index

      _(collection.toArray()).chain().clone().each (book) ->
        book.destroy()

      expect(collection.length).toEqual 0 # 'item was destroyed and collection is empty'
      collection.fetch()
      expect(collection.length).toEqual 0 # 'item was destroyed and collection is empty even after fetch'

    it 'should not try to load items from localstorage if they are not there anymore', ->
      collection.create Factory.build('post')
      storageKey = collection.localStorage.storageKeyFor collection.models[0]
      localStorage.removeItem storageKey
      collection.fetch()
      expect(0).toEqual collection.length #

    it 'should load from session store without server request', ->
      collection.create Factory.build('post')
      secondTestCollection = new TestCollection([], modelName: 'TestModel')
      secondTestCollection.fetch()
      expect(1).toEqual secondTestCollection.length #

    it 'should cope with arbitrary idAttributes', ->
      Model = Backbone.Model.extend(idAttribute: '_id')
      Collection = Backbone.Collection.extend(
        model: Model
        localStorage: new Store('strangeID')
      )
      collection = new Collection([], modelName: 'TestModel')
      collection.create {}
      expect(collection.first().id).toEqual collection.first().get('_id') #

  describe 'localStorage on models', ->

    TestModel = Backbone.Model.extend(
      defaults:
        title: 'The Tempest'
        author: 'Bill Shakespeare'
        length: 123
    )

    model = undefined

    beforeEach ->
      TestModel::localStorage = new Backbone.LocalStorage('TestModel')
      model = new TestModel()

    afterEach ->
      model.destroy()
      model.localStorage._cleanup()

    it 'should overwrite unsaved changes when fetching', ->
      model.save()
      model.set title: 'Wombat\'s Fun Adventure'
      model.fetch()
      expect(model.get('title')).toEqual 'The Tempest' # 'model created'

    it 'should persist changes', ->
      model.save author: 'William Shakespeare'
      model.fetch()
      expect(model.get('author')).toEqual 'William Shakespeare' # 'author successfully updated'
      expect(model.get('length')).toEqual 123 # 'verify length is still there'

    it 'should remove model when destroying', ->
      model.save author: 'fnord'
      expect(TestModel::localStorage.findAll().length).toEqual 1 # 'model removed'
      model.destroy()
      expect(TestModel::localStorage.findAll().length).toEqual 0 # 'model removed'

    it 'should use local sync', ->
      method = Backbone.getSyncMethod(model)
      expect(method).toEqual Backbone.localSync #

    it 'remoteModel should use ajax sync', ->
      class MyRemoteModel extends Backbone.Model
      remoteModel = new MyRemoteModel()
      method = Backbone.getSyncMethod(remoteModel)
      expect(method).toEqual Backbone.ajaxSync #

  describe '#constructor', ->
    beforeEach ->
      window.localStorage.setItem('TestCollection-lastSynced', JSON.stringify 'timestamp')
      @localStorage = new Backbone.LocalStorage('TestCollection')

    afterEach ->
      @localStorage._cleanup()

    it 'initializes lastSynced from the localStorage', ->
      expect(@localStorage.lastSynced).toEqual('timestamp')

  describe '#save', ->
    beforeEach ->
      @localStorage = new Backbone.LocalStorage('TestCollection')

    afterEach ->
      @localStorage._cleanup()

    it 'saves the last_synced timestamp to the localstorage', ->
      @localStorage.lastSynced = 'timestamp'
      @localStorage.save()
      expect(
        JSON.parse window.localStorage.
          getItem("#{@localStorage.name}-lastSynced")
      ).toEqual('timestamp')

  describe '#versioningKeyFor', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      TestCollection::localStorage = new Backbone.
                                       LocalStorage('TestCollection')
      @collection = new TestCollection
      @model = @collection.create Factory.build('answer', id: null)

    afterEach ->
      @collection._cleanup()

    it 'returns the storage key for the model appended with -versioning', ->
      expect(@collection.localStorage.versioningKeyFor(@model)).
        toEqual "#{@collection.localStorage.storageKeyFor(@model)}-versioning"

  describe '#create', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      class OtherTestCollection extends Backbone.Collection
      TestCollection::localStorage = new Backbone.
                                       LocalStorage('TestCollection')
      OtherTestCollection::localStorage = new Backbone.
                                            LocalStorage('OtherTestCollection')
      @collection = new TestCollection([], modelName: 'TestModel')
      @other_collection = new OtherTestCollection([], modelName: 'TestModel')

    afterEach ->
      @collection._cleanup()
      @other_collection._cleanup()

    it 'generates a unique object id within the scope of a collection', ->
      sinon.stub @collection.localStorage, 'guid', ->
        @ids ||= ['other_unique_id', 'unique_id', 'used_id']
        @ids.pop()
      # this id is in use in the same collection
      @collection.create id: 'used_id'
      # this id is in use in another collection
      @other_collection.create id: 'unique_id'
      @collection.create Factory.build('answer', id: null)
      # last model has a unique id within collection scope
      expect(@collection.last().get('id')).toEqual 'unique_id'

  describe '#update', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')
      @localStorage = new Backbone.LocalStorage('TestModel')
      @saveVersioningForStub = sinon.stub(@localStorage, 'saveVersioningFor')

    afterEach ->
      @saveVersioningForStub.restore()
      @localStorage.destroy(@model)
      @localStorage._cleanup()

    it 'saves the versioning of the model', ->
      @localStorage.update(@model)
      expect(@saveVersioningForStub).toHaveBeenCalledWith(@model)

  describe '#saveVersioningFor', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
        id: 'some_id'
      @model.localStorage = new Backbone.LocalStorage('TestModel')
      @model._versioning = {patches: ["some", "patches"]}
      @model.collection =
        url: '/collection' # stub the model's collection url

    afterEach ->
      @model.localStorage.destroy(@model)
      @model.localStorage._cleanup()

    it 'saves the model\'s _versioning object to localStorage', ->
      @model.localStorage.saveVersioningFor(@model)
      expect(window.localStorage.
               getItem('TestModel-' + @model.id + '-versioning')).
        toEqual JSON.stringify(@model._versioning)

  describe '#find', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer', id: 'test_id')
      @model.localStorage = new Backbone.LocalStorage('TestModel')
      @model.collection =
        url: '/collection' # stub the model's collection url
      @model.save()

    afterEach ->
      @model.destroy()
      @model.localStorage._cleanup()

    it 'fetches _versioning from localStorage', ->
      versioning = {patches: ['some', 'patches']}
      window.localStorage.
        setItem 'TestModel-test_id-versioning',
                JSON.stringify(versioning)
      @model.fetch()
      expect(@model._versioning).toEqual versioning

  describe '#findAll', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @setAllVersioningStub = sinon.stub Backbone.LocalStorage::, 'setAllVersioning'
      @setVersioningStub = sinon.stub Backbone.LocalStorage::, 'setVersioning'
      TestCollection::localStorage = new Backbone.
                                       LocalStorage('TestCollection')
      @collection = new TestCollection([], modelName: 'TestModel')
      @collection.create Factory.build('answer')

    afterEach ->
      @setAllVersioningStub.restore()
      @setVersioningStub.restore()
      @collection._cleanup()

    it 'binds setAllVersioning to the collection reset event', ->
      @collection.fetch()
      expect(@setAllVersioningStub).toHaveBeenCalled()

    it 'binds setVersioning to the collection add event', ->
      @collection.reset()
      @collection.fetch(add: true)
      expect(@setVersioningStub).toHaveBeenCalled()

  describe '#setAllVersioning', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @setVersioningStub = sinon.stub Backbone.LocalStorage::, 'setVersioning'
      TestCollection::localStorage = new Backbone.
                                       LocalStorage('TestCollection')
      @collection = new TestCollection([], modelName: 'TestModel')
      @collection.create Factory.build('answer')

    afterEach ->
      @setVersioningStub.restore()
      @collection._cleanup()

    it 'calls setVersioning for all models in a collection', ->
      @collection.fetch()
      expect(@setVersioningStub).toHaveBeenCalled()

  describe '#setVersioning', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      TestCollection::localStorage = new Backbone.
                                       LocalStorage('TestCollection')
      @collection = new TestCollection([], modelName: 'TestModel')
      @collection.create Factory.build('answer', id: 'test_id')

    afterEach ->
      @collection._cleanup()

    it 'fetches _versioning for a model being added to a collection', ->
      versioning = {patches: ['some', 'patches']}
      window.localStorage.
        setItem 'TestCollection-test_id-versioning',
                JSON.stringify(versioning)
      @collection.reset()
      @collection.fetch(add: true)
      expect(@collection.models[0]._versioning).toEqual versioning

  describe '#destroy', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer', id: 'test_id')
      @model.localStorage = new Backbone.LocalStorage('TestModel')
      @model.collection =
        url: '/collection' # stub the model's collection url

    afterEach ->
      @model.destroy()
      @model.localStorage._cleanup()

    it 'cleans up the versioning in localStorage after destroing', ->
      @model._versioning = {patches: ['some', 'patches']}
      @model.save()
      expect(window.localStorage.
               getItem('TestModel-' + @model.id + '-versioning')).
        toEqual JSON.stringify(@model._versioning)
      @model.destroy()
      expect(window.localStorage.
               getItem('TestModel-' + @model.id + '-versioning')).
        toBeNull()






