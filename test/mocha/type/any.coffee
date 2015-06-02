require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'

describe "Any", ->

  schema = null
  beforeEach ->
    schema =
      type: 'any'

  describe "base check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

  describe "simple check", ->

    it "should match boolean", (cb) ->
      test.same schema, [true, false], cb

    it "should match float objects", (cb) ->
      test.same schema, [1.0, -12.3, 2678.999, 10], cb

    it "should match integer objects", (cb) ->
      test.same schema, [1, -12, 2678], cb

    it "should match string objects", (cb) ->
      test.same schema, ['hello', '1', ''], cb

    it "should match array objects", (cb) ->
      test.same schema, [
        [1,2,3]
        ['one','two']
        []
        new Array()
      ], cb

    it "should match functions", (cb) ->
      test.same schema, [beforeEach, RegExp, Array], cb

    it "should match an object", (cb) ->
      test.same schema, [{one:1,two:2,three:3}, new Error 'xxx'], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'boolean'
        optional: true
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'boolean'
        optional: true
      , cb
