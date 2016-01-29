test = require '../../test'
### eslint-env node, mocha ###

describe "Or", ->

  schema = null
  beforeEach ->
    schema =
      type: 'or'
      or: [
        type: 'integer'
      ,
        type: 'boolean'
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

    it "should match boolean", (cb) ->
      test.same schema, [true, false], cb

    it "should match boolean", (cb) ->
      test.fail schema, [15.3, '', [], (new Error '????'), {}], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'or'
        or: [
          type: 'integer'
        ,
          type: 'string'
        ]
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'or'
        or: [
          type: 'integer'
        ,
          type: 'string'
        ]
      , cb
