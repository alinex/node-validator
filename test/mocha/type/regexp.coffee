async = require 'alinex-async'

test = require '../../test'

describe "RegExp", ->

  schema = null
  beforeEach ->
    schema =
      type: 'regexp'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = /s/
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match expressions", (cb) ->
      test.same schema, [/test/, /^[1-9]test/g], cb

    it "should match string expressions", (cb) ->
      test.equal schema, [
        ['/test/', /test/]
      ], cb

    it "should match all modifiers", (cb) ->
      test.equal schema, [
        ['/s/g', /s/g]
        ['/s/i', /s/i]
        ['/s/m', /s/m]
      ], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, ['hello', null, [], (new Error '????'), {},
      '/hello', '/he(llo/'], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb
