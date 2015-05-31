require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'

describe "Boolean", ->

  schema = null
  beforeEach ->
    schema =
      type: 'boolean'

  describe "base check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = true
      test.true schema, [null, undefined], cb

  describe "simple check", ->

    it "should match true", (cb) ->
      test.true schema, ['true', '1', 'on', 'yes', '+', 1, true], cb

    it "should match false", (cb) ->
      test.false schema, ['false', '0', 'off', 'no', '-', 0, false], cb

    it "should match numbers", (cb) ->
      test.true schema, [1, 1.0], ->
        test.false schema, [0, 0x0000], cb

    it "should match uppercase", (cb) ->
      test.true schema, ['True', 'ON'], ->
        test.false schema, ['False', 'OFF'], cb

    it "should match with spaces", (cb) ->
      test.true schema, ['True  ', ' ON '], cb

    it "should fail on undefined", (cb) ->
      test.fail schema, [null, undefined, ''], cb

    it "should fail on other strings", (cb) ->
      test.fail schema, ['Hello', 'Nobody', 'o'], cb

    it "should fail on other numbers", (cb) ->
      test.fail schema, [3, -1, 0.1], cb

    it "should fail on other types", (cb) ->
      test.fail schema, [[], new Error('????'), {}], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'boolean'
        optional: true
        default: true
      , cb

  describe.skip "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'boolean'
        optional: true
        default: true
      , cb
