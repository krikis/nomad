describe "localStorage on collections", ->

  TestCollection = Backbone.Collection.extend()
  collection = undefined

  beforeEach ->
    window.localStorage.clear()
    TestCollection::localStorage = new Backbone.LocalStorage("TestCollection")
    collection = new TestCollection()

  it "should be empty initially", ->
    expect(collection.length).toEqual 0 # "empty initially"
    collection.fetch()
    expect(collection.length).toEqual 0 # "empty read"

  it "should create item", ->
    collection.create Factory.build('post')
    expect(collection.length).toEqual 1 # "one item added"
    expect(collection.first().get("title")).toEqual "The Tempest" # "title was read"
    expect(collection.first().get("author")).toEqual "Bill Shakespeare" # "author was read"
    expect(collection.first().get("length")).toEqual 123 # "length was read"

  it "should discard unsaved changes on fetch", ->
    collection.create Factory.build('post')
    collection.first().set title: "Wombat's Fun Adventure"
    expect(collection.first().get("title")).toEqual "Wombat's Fun Adventure" # "title changed, but not saved"
    collection.fetch()
    expect(collection.first().get("title")).toEqual "The Tempest" # "title was read"

  it "should persist changes", ->
    collection.create Factory.build('post')
    expect(collection.first().get("author")).toEqual "Bill Shakespeare" # "author was read"
    collection.first().save author: "William Shakespeare"
    collection.fetch()
    expect(collection.first().get("author")).toEqual "William Shakespeare" # "verify author update"

  it "should allow to change id", ->
    collection.create Factory.build('post')
    collection.first().save
      id: "1-the-tempest"
      author: "William Shakespeare"

    expect(collection.first().get("id")).toEqual "1-the-tempest" # "verify ID update"
    expect(collection.first().get("title")).toEqual "The Tempest" # "verify title is still there"
    expect(collection.first().get("author")).toEqual "William Shakespeare" # "verify author update"
    expect(collection.first().get("length")).toEqual 123 # "verify length is still there"
    collection.fetch()
    expect(collection.length).toEqual 2 # "should not auto remove first object when changing ID"

  it "should remove from collection", ->
    _(23).times (index) ->
      collection.create id: index

    _(collection.toArray()).chain().clone().each (book) ->
      book.destroy()

    expect(collection.length).toEqual 0 # "item was destroyed and collection is empty"
    collection.fetch()
    expect(collection.length).toEqual 0 # "item was destroyed and collection is empty even after fetch"

  it "should not try to load items from localstorage if they are not there anymore", ->
    collection.create Factory.build('post')
    localStorage.clear()
    collection.fetch()
    expect(0).toEqual collection.length #

  it "should load from session store without server request", ->
    collection.create Factory.build('post')
    secondTestCollection = new TestCollection()
    secondTestCollection.fetch()
    expect(1).toEqual secondTestCollection.length #

  it "should cope with arbitrary idAttributes", ->
    Model = Backbone.Model.extend(idAttribute: "_id")
    Collection = Backbone.Collection.extend(
      model: Model
      localStorage: new Store("strangeID")
    )
    collection = new Collection()
    collection.create {}
    expect(collection.first().id).toEqual collection.first().get("_id") #

describe "localStorage on models", ->

  TestModel = Backbone.Model.extend(
    defaults:
      title: "The Tempest"
      author: "Bill Shakespeare"
      length: 123
  )

  model = undefined

  beforeEach ->
    window.localStorage.clear()
    TestModel::localStorage = new Backbone.LocalStorage("TestModel")
    model = new TestModel()

  it "should overwrite unsaved changes when fetching", ->
    model.save()
    model.set title: "Wombat's Fun Adventure"
    model.fetch()
    expect(model.get("title")).toEqual "The Tempest" # "model created"

  it "should persist changes", ->
    model.save author: "William Shakespeare"
    model.fetch()
    expect(model.get("author")).toEqual "William Shakespeare" # "author successfully updated"
    expect(model.get("length")).toEqual 123 # "verify length is still there"

  it "should remove model when destroying", ->
    model.save author: "fnord"
    expect(TestModel::localStorage.findAll().length).toEqual 1 # "model removed"
    model.destroy()
    expect(TestModel::localStorage.findAll().length).toEqual 0 # "model removed"

  it "should use local sync", ->
    method = Backbone.getSyncMethod(model)
    expect(method).toEqual Backbone.localSync #

  it "remoteModel should use ajax sync", ->
    MyRemoteModel = Backbone.Model.extend()
    remoteModel = new MyRemoteModel()
    method = Backbone.getSyncMethod(remoteModel)
    expect(method).toEqual Backbone.ajaxSync #

describe "#create", ->
  TestCollection = Backbone.Collection.extend()
  OtherTestCollection = Backbone.Collection.extend()
  collection = undefined
  other_collection = undefined
  ids = undefined

  beforeEach ->
    window.localStorage.clear()
    TestCollection::localStorage = new Backbone.LocalStorage("TestCollection")
    OtherTestCollection::localStorage = new Backbone.LocalStorage("OtherTestCollection")
    collection = new TestCollection()
    other_collection = new OtherTestCollection()

  it "should generate a unique object id within the scope of a collection", ->
    sinon.stub collection.localStorage, "guid", ->
      ids ||= ["other_unique_id", "unique_id", "used_id"]
      id = ids.pop()
    collection.create id: "used_id"         # this id is in use in the same collection
    other_collection.create id: "unique_id" # this id is in use in another collection
    collection.create
      title: "The Tempest"
      author: "Bill Shakespeare"
      length: 123
    # last model has a unique id within collection scope
    expect(collection.last().get("id")).toEqual "unique_id"


