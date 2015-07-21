async = require 'alinex-async'

test = require '../../test'

describe "TCP/UDP Port", ->

  schema = null
  beforeEach ->
    schema =
      type: 'port'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 80
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match normal values", (cb) ->
      test.same schema, [22, 80, 62016], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, [null, [], (new Error '????'), { }], cb

    it "should fail on incorrect values", (cb) ->
      test.fail schema, [-1, 3.5, 1234567890], cb

  describe "options check", ->

    it "should transform names", (cb) ->
      test.equal schema, [
        ['http', 80]
        ['ssh', 22]
      ], cb

    it "should support deny range", (cb) ->
      schema.deny = [
        8080
        'system'
      ]
      test.same schema, [8081, 12121], ->
        test.fail schema, [80, 8080], cb

    it "should support allow range", (cb) ->
      schema.allow = [
        8080
        'system'
      ]
      test.same schema, [80, 8080], ->
        test.fail schema, [8081, 12121], cb

    it "should support deny with allow range", (cb) ->
      schema.deny = ['system']
      schema.allow = [80]
      test.same schema, [80, 1024], ->
        test.fail schema, [88, 443], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'port'
        optional: true
        default: 80
        deny: ['system']
        allow: [80]
      , cb

  describe.only "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'port'
        optional: true
        default: 80
        deny: ['system']
        allow: [80]
      , cb
