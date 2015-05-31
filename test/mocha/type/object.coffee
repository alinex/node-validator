require('alinex-error').install()
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
      test.same schema, [{ one:1, two:2 }], ->
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
      schema.mandatoryKeys = ['three']
      test.same schema, [{ one:1, two:2, three:3 }], ->
        test.fail schema, [{ one:1, two:2 }], cb

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
        mandatoryKeys: ['one']
        allowedKeys: true
        keys:
          one:
            type: 'integer'
          two:
            type: 'string'
      , cb

  describe.skip "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck options, cb

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
        mandatoryKeys: ['one']
        allowedKeys: ['two']
        entries:
          one:
            type: 'integer'
          two:
            type: 'string'
      , cb
