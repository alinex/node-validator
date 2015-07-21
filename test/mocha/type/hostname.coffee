async = require 'alinex-async'

test = require '../../test'

describe "Hostname", ->

  schema = null
  beforeEach ->
    schema =
      type: 'hostname'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 'localhost'
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match normal names", (cb) ->
      test.same schema, ['localhost', 'mypc', 'my-pc'], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, [null, [], (new Error '????'), {}], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'hostname'
        optional: true
        default: 'nix'
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'hostname'
        optional: true
        default: 'nix'
      , cb
