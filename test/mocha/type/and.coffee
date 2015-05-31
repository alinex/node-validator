require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'

describe.only "And", ->

  schema = null
  beforeEach ->
    schema =
      type: 'and'
      entries: [
        type: 'string'
        toString: true
        replace: [/,/g, '.']
      ,
        type: 'float'
      ]

  describe "base check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 1
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match integer", (cb) ->
      test.same schema, [1, -12, 3678], cb

    it "should match float", (cb) ->
      test.same schema, [1.7, -12.8, 3678.6], cb

    it "should match float (german notation)", (cb) ->
      test.equal schema, [
        ['1,7', 1.7]
        ['-12,8', -12.8]
        ['3678,6', 3678.6]
      ], cb

    it "should fail for and selection", (cb) ->
      test.fail schema, ['', [], (new Error '????'), {}], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'and'
        entries: [
          type: 'string'
        ,
          type: 'integer'
        ]
      , cb

  describe.skip "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'any'
        entries: [
          type: 'integer'
        ,
          type: 'string'
        ]
      , cb

