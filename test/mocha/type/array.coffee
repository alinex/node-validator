test = require '../../test'
### eslint-env node, mocha ###

describe "Array", ->

  schema = null
  beforeEach ->
    schema =
      type: 'array'

  describe "base check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = [1, 2, 3]
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match array objects", (cb) ->
      test.same schema, [
        [1,2,3]
        ['one','two']
        []
        new Array()
      ], cb

    it "should fail on other objects", (cb) ->
      test.fail schema, ['', null, 16, (new Error '????'), {}], cb

    it "should run check on all sub elements", (cb) ->
      test.same schema, [
        [[1],2,[3]]
        ['one', {two: 2}]
        new Array()
      ], cb

  describe "option check", ->

    it "should support delimiter option", (cb) ->
      schema.delimiter = ','
      test.equal schema, [
        ['1,2,3', ['1','2','3']]
        ['123', ['123']]
      ], cb

    it "should support toArray option", (cb) ->
      schema.toArray = ','
      test.equal schema, [
        ['123', ['123']]
        [15, [15]]
        [(new Error 'xxx'), [(new Error 'xxx')]]
        [[1,2,3], [1,2,3]]
      ], cb

    it "should support notEmpty option", (cb) ->
      schema.notEmpty = true
      test.same schema, [[1,2,3], ['one','two']], ->
        test.fail schema, [[], new Array()], cb

    it "should support minLength option", (cb) ->
      schema.minLength = 2
      test.same schema, [[1,2,3], ['one','two']], ->
        test.fail schema, [[], new Array(), [1]], cb

    it "should support maxLength option", (cb) ->
      schema.maxLength = 2
      test.same schema, [[1], ['one','two'], [], new Array()], ->
        test.fail schema, [[1,2,3]], cb

    it "should support exact length option", (cb) ->
      schema.minLength = 2
      schema.maxLength = 2
      test.same schema, [[1,2], ['one','two']], ->
        test.fail schema, [[1,2,3], [1], []], cb

    it "should support default subchecks", (cb) ->
      schema.entries =
        type: 'integer'
      test.same schema, [[1,2], []], ->
        test.fail schema, [['one'], [1,'two']], cb

    it "should support specific subchecks", (cb) ->
      schema.list = [
        type: 'integer'
      ,
        type: 'float'
      ]
      test.same schema, [[1,2.0], [], [-1,0.7]], ->
        test.fail schema, [[1.5,2.0], [-1.4,0]], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give simple list description", (cb) ->
      test.describe
        type: 'array'
        delimiter: ','
        toArray: true
        entries:
          type: 'integer'
      , cb

    it "should give complex list description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'array'
        list: [
          type: 'integer'
        ,
          type: 'string'
        ]
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate simple list", (cb) ->
      test.selfcheck
        type: 'array'
        delimiter: ','
        toArray: true
        entries:
          type: 'integer'
      , cb

    it "should validate complex list", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'array'
        list: [
          type: 'integer'
        ,
          type: 'string'
        ]
      , cb
