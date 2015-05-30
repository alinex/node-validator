require('alinex-error').install()
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

    it "should give simple description", ->
      test.describe schema

    it "should give complete description", ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'function'
        optional: true
        default: RegExp

  describe.skip "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck schema

    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'function'
        optional: true
        default: RegExp
