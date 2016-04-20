test = require '../../test'
### eslint-env node, mocha ###

describe "Email", ->

  schema = null
  beforeEach ->
    schema =
      type: 'email'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 'root@localhost'
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "problems", ->

    it "should fail invalid email adresses", (cb) ->
      test.fail schema, [
        'info alinex.de'
        'info@alinex@de'
        'this.is.a.very.long.local.part.which.should.be.to.long.to.be.valid.as.an.email.address@email.de'
      ], cb

  describe "simple check", ->

    it "should match normal email adresses", (cb) ->
      test.same schema, ['alexander.schilling@divibib.com', 'info@alinex.de'], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, [null, [], (new Error '????'), {}], cb

  describe "options", ->

    it "should allow local mailboxes", (cb) ->
      test.same schema, ['alexander@localhost'], cb

    it "should make host lowercase", (cb) ->
      test.equal schema, [
        ['Alexander@LOCALHOST', 'Alexander@localhost']
        ['Info@Alinex.DE', 'Info@alinex.de']
      ], cb

    it "should allow lowercase", (cb) ->
      schema.lowerCase = true
      test.equal schema, [
        ['Alexander@LOCALHOST', 'alexander@localhost']
        ['Info@Alinex.DE', 'info@alinex.de']
      ], cb

    it "should allow normalization", (cb) ->
      schema.normalize = true
      test.equal schema, [
        ['Alexander+test@LOCALHOST', 'Alexander@localhost']
        ['alexander.schilling+test@googlemail.com', 'alexanderschilling@gmail.com']
      ], cb

    it "should check server", (cb) ->
      @timeout 5000
      schema.checkServer = true
      test.same schema, ['alexander.schilling@divibib.com', 'info@alinex.de'], cb

    it "should fail to check server", (cb) ->
      @timeout 5000
      schema.checkServer = true
      test.fail schema, ['alexander.schilling@nqqnnddajc.de'], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'email'
        optional: true
        default: 'root@localhost'
        lowerCase: true
        normalize: true
        checkServer: true
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'email'
        optional: true
        default: 'root@localhost'
        lowerCase: true
        normalize: true
        checkServer: true
      , cb
