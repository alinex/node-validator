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
      test.same schema, [{one:1,two:2,three:3}], cb

    it.only "should fail on other elements", (cb) ->
      test.fail schema, [null, 16, [], new Error 'xxx'], cb



    it "should support optional option", (cb) ->
      options =
        type: 'object'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support instanceOf option", (cb) ->
      options =
        type: 'object'
        instanceOf: Date
      test.instance options, new Date(), Date
    it "should fail for instanceOf option", (cb) ->
      options =
        type: 'object'
        instanceOf: Date
      test.fail options, new Object()
      test.fail options, []
    it "should support allowedKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: true
        entries:
          one:
            type: 'integer'
          two:
            type: 'integer'
      test.deep options, { one:1, two:2 }, { one:1, two:2 }
    it "should fail for allowedKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: true
        entries:
          one:
            type: 'integer'
          two:
            type: 'integer'
      test.fail options, { one:1, two:2, three:3 }
    it "should support allowedKeys list option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
      test.deep options, { one:1, two:2 }, { one:1, two:2 }
    it "should fail for allowedKeys list option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
      test.fail options, { one:1, two:2, three:3 }
    it "should support allowedKeys regexp option", (cb) ->
      options =
        type: 'object'
        allowedKeys: /o/
      test.deep options, { one:1, two:2 }, { one:1, two:2 }
    it "should fail for allowedKeys list option", (cb) ->
      options =
        type: 'object'
        allowedKeys: /o/
      test.fail options, { one:1, two:2, three:3 }
    it "should support mandatoryKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
        mandatoryKeys: ['three']
      test.deep options, { one:1, two:2, three:3 }, { one:1, two:2, three:3 }
      test.deep options, { three:3 }, { three:3 }
    it "should fail for mandatoryKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
        mandatoryKeys: ['three']
      test.fail options, { one:1, two:2, four:3 }
      test.fail options, { one:1, two:2 }
    it "should support subchecks", (cb) ->
      options =
        type: 'object'
        entries:
          one:
            type: 'integer'
      test.deep options, { one:1, two:2, three:3 }, { one:1, two:2, three:3 }
      test.deep options, { one:100, three:3 }, { one:100, three:3 }
    it "should fail on subchecks", (cb) ->
      options =
        type: 'object'
        entries:
          one:
            type: 'integer'
      test.fail options, { one:1.1, two:2, three:3 }
      test.fail options, { two:2, three:3, one:'nnn' }
    it "should support allowed subcheck values", (cb) ->
      options =
        type: 'object'
        allowedKeys: true
        entries:
          one:
            type: 'integer'
      test.deep options, { one:1}, { one:1 }
    it "should fail on not allowed subcheck values", (cb) ->
      options =
        type: 'object'
        allowedKeys: true
        entries:
          one:
            type: 'integer'
      test.fail options, { one:1, two:2, three:3 }
    it "should support same check for all keys", (cb) ->
      options =
        type: 'object'
        entries:
          type: 'integer'
      test.deep options, { one:1}, { one:1 }

  describe "async check", (cb) ->

    it "should match an object", (cb) ->
      async.series [
        (cb) -> test.deep options, {one:1,two:2,three:3}, {one:1,two:2,three:3}, cb
      ], cb
    it "should fail on other elements", (cb) ->
      async.series [
        (cb) -> test.fail options, '', cb
        (cb) -> test.fail options, null, cb
        (cb) -> test.fail options, 16, cb
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, new Array(), cb
      ], cb
    it "should support optional option", (cb) ->
      options =
        type: 'object'
        optional: true
      async.series [
        (cb) -> test.same options, null, cb
        (cb) -> test.same options, undefined, cb
      ], cb
    it "should support instanceOf option", (cb) ->
      options =
        type: 'object'
        instanceOf: Date
      async.series [
        (cb) -> test.instance options, new Date(), Date, cb
      ], cb
    it "should fail for instanceOf option", (cb) ->
      options =
        type: 'object'
        instanceOf: Date
      async.series [
        (cb) -> test.fail options, new Object(), cb
        (cb) -> test.fail options, [], cb
      ], cb
    it "should support allowedKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
      async.series [
        (cb) -> test.deep options, { one:1, two:2 }, { one:1, two:2 }, cb
      ], cb
    it "should fail for allowedKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
      async.series [
        (cb) -> test.fail options, { one:1, two:2, three:3 }, cb
      ], cb
    it "should support mandatoryKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
        mandatoryKeys: ['three']
      async.series [
        (cb) -> test.deep options, { one:1, two:2, three:3 }, { one:1, two:2, three:3 }, cb
        (cb) -> test.deep options, { three:3 }, { three:3 }, cb
      ], cb
    it "should fail for mandatoryKeys option", (cb) ->
      options =
        type: 'object'
        allowedKeys: ['one','two']
        mandatoryKeys: ['three']
      async.series [
        (cb) -> test.fail options, { one:1, two:2, four:3 }, cb
        (cb) -> test.fail options, { one:1, two:2 }, cb
      ], cb
    it "should support subchecks", (cb) ->
      options =
        type: 'object'
        entries:
          one:
            type: 'integer'
      async.series [
        (cb) -> test.deep options, { one:1, two:2, three:3 }, { one:1, two:2, three:3 }, cb
        (cb) -> test.deep options, { one:100, three:3 }, { one:100, three:3 }, cb
      ], cb
    it "should fail on subchecks", (cb) ->
      options =
        type: 'object'
        entries:
          one:
            type: 'integer'
      async.series [
        (cb) -> test.fail options, { one:1.1, two:2, three:3 }, cb
        (cb) -> test.fail options, { two:2, three:3, one:'nnn' }, cb
      ], cb
    it "should support allowed subcheck values", (cb) ->
      options =
        type: 'object'
        allowedKeys: true
        entries:
          one:
            type: 'integer'
      async.series [
        (cb) -> test.deep options, { one:1}, { one:1 }, cb
      ], cb
    it "should fail on not allowed subcheck values", (cb) ->
      options =
        type: 'object'
        allowedKeys: true
        entries:
          one:
            type: 'integer'
      async.series [
        (cb) -> test.fail options, { one:1, two:2, three:3 }, cb
      ], cb
    it "should support same check for all keys", (cb) ->
      options =
        type: 'object'
        entries:
          type: 'integer'
      async.series [
        (cb) -> test.deep options, { one:1}, { one:1 }, cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give instance description", ->
      test.desc
        type: 'object'
        instanceOf: RegExp
    it "should give complex object description", ->
      test.desc
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

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate instance options", ->
      test.selfcheck
        type: 'object'
        instanceOf: RegExp
    it "should validate complex object", ->
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
