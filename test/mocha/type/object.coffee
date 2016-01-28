async = require 'alinex-async'

test = require '../../test'

describe "Object", ->

  schema = null
  beforeEach ->
    schema =
      type: 'object'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = {one:1}
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match an object", (cb) ->
      test.same schema, [{one:1,two:2,three:3}, new Error 'xxx'], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, [null, 16, []], cb

    it "should run check on all sub elements", (cb) ->
      test.same schema, [
        {array: [1], number: 2, list: [3]}
        {string: 'one', map: {two: 2}}
      ], cb

  describe "options check", ->

    it "should support instanceOf option", (cb) ->
      schema.instanceOf = Date
      test.same schema, [new Date()], ->
        test.fail schema, [new Object(), [], new Error 'xxx'], cb

    it "should support allowedKeys option", (cb) ->
      schema.allowedKeys = true
      schema.keys =
        one:
          type: 'integer'
        two:
          type: 'integer'
      schema.entries = [
        { key: /test\d/, type: 'integer' }
      ]
      test.same schema, [{ one:1, two:2, test1:1 }], ->
        test.fail schema, [{ one:1, two:2, three:3 }], cb

    it "should support allowedKeys list option", (cb) ->
      schema.allowedKeys = ['one','two']
      test.same schema, [{ one:1, two:2 }], ->
        test.fail schema, [{ one:1, two:2, three:3 }], cb

    it "should support allowedKeys regexp option", (cb) ->
      schema.allowedKeys = [/o/]
      test.same schema, [{ one:1, two:2 }], ->
        test.fail schema, [{ one:1, two:2, three:3 }], cb

    it "should support mandatoryKeys option", (cb) ->
      schema.mandatoryKeys = true
      schema.keys =
        one:
          type: 'integer'
        two:
          type: 'integer'
      schema.entries = [
        { key: /test\d/, type: 'integer' }
      ]
      test.same schema, [{ one:1, two:2, three:3, test1:1 }], ->
        test.fail schema, [{ one:1, three:3 }], cb

    it "should support mandatoryKeys list option", (cb) ->
      schema.mandatoryKeys = ['three']
      test.same schema, [{ one:1, two:2, three:3 }], ->
        test.fail schema, [{ one:1, two:2 }], ->
          schema.mandatoryKeys = [/test\d/]
          test.fail schema, [{ one:1, two:2 }], cb

    it "should support mandatory and allowedKeys together", (cb) ->
      schema.mandatoryKeys = ['one']
      schema.allowedKeys = ['two']
      test.same schema, [{ one:1, two:2 }], ->
        test.fail schema, [{ one:1, two:2, three:3 }], cb

    it "should support subchecks", (cb) ->
      schema.keys =
          one:
            type: 'integer'
      test.same schema, [{ one:1, two:2, three:3 }, { one:100, two:2 }], ->
        test.fail schema, [{ one:1.1, two:2 }, { one:'nnn', two:2 }], cb

    it "should support default check for all keys", (cb) ->
      schema.entries = [
        type: 'integer'
      ]
      test.same schema, [{ one:1, two:2, three:3 }, { one:100, two:2 }], ->
        test.fail schema, [{ one:1.1, two:2 }, { one:'nnn', two:2 }], cb

  describe "subchecks", ->

    it "should support optional option", (cb) ->
      schema.allowedKeys = true
      schema.keys =
        one:
          type: 'integer'
        two:
          type: 'integer'
          optional: true
      test.equal schema, [
        [
          { one: 1, two: null }
          { one: 1 }
        ]
        [
          { one: null, two: 2 }
          { two: 2 }
        ]
      ], cb

    it "should support default option", (cb) ->
      schema.allowedKeys = true
      schema.keys =
        one:
          type: 'integer'
        max:
          type: 'integer'
          default: 5
      test.equal schema, [
        [
          { one: 1, two: null }
          { one: 1, max: 5 }
        ]
      ], cb

    it "should support optional in mandatory option", (cb) ->
      schema.mandatoryKeys = true
      schema.keys =
        one:
          type: 'integer'
        two:
          type: 'integer'
          optional: true
      test.equal schema, [
        [
          { one: 1, two: null }
          { one: 1 }
        ]
      ], cb

    it "should support default in mandatory option", (cb) ->
      schema.mandatoryKeys = true
      schema.keys =
        one:
          type: 'integer'
        max:
          type: 'integer'
          default: 5
      test.equal schema, [
        [
          { one: 1, two: null }
          { one: 1, max: 5}
        ]
      ], cb

    it "should support flat objects", (cb) ->
      schema.flatten = true
      test.equal schema, [
        [
          { num: { one: 1, two: 2 } }
          { num: { one: 1, two: 2 } }
        ,
          { first: { num: { one: 1, two: 2 } } }
          { 'first-num': { one: 1, two: 2 } }
        ]
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give instance description", (cb) ->
      test.describe
        type: 'object'
        instanceOf: RegExp
      , cb

    it "should give complex object description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'object'
        flatten: true
        mandatoryKeys: true
        allowedKeys: true
        instanceOf: Object
        entries: [
          key: /^num-\d+/
          type: 'integer'
        ,
          type: 'string'
        ]
        keys:
          one:
            type: 'integer'
          two:
            type: 'string'
      , cb

    it "should give allowedKeys description", (cb) ->
      test.describe
        type: 'object'
        allowedKeys: ['one', 'two']
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate instance options", (cb) ->
      test.selfcheck
        type: 'object'
        instanceOf: RegExp
      , cb

    it "should validate complex object", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'object'
        flatten: true
        mandatoryKeys: ['one']
        allowedKeys: ['two']
        keys:
          one:
            type: 'integer'
          two:
            type: 'string'
      , cb
