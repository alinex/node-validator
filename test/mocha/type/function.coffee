async = require 'alinex-async'

test = require '../../test'

describe "Function", ->

  schema = null
  beforeEach ->
    schema =
      type: 'function'

  describe "base check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = beforeEach
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match functions", (cb) ->
      test.same schema, [beforeEach, RegExp, Array], cb

    it "should fail on undefined", (cb) ->
      test.fail schema, [null, undefined, new Error 'xxx'], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'function'
        optional: true
        default: RegExp
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'function'
        optional: true
        default: RegExp
      , cb