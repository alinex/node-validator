require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'

describe "Float", ->

  schema = null
  beforeEach ->
    schema =
      type: 'float'

  describe "base check", ->

    it.only "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = true
      test.true schema, [null, undefined], cb

  describe "sync check", ->

    it "should match float objects", ->
      test.equal options, 1.0, 1
      test.equal options, -12.3, -12.3
      test.equal options, '3678.999', 3678.999
      test.equal options, 10, 10
    it "should fail on other objects", ->
      test.fail options, ''
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'float'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support sanitize option", ->
      options =
        type: 'float'
        sanitize: true
      test.equal options, 'go4now', 4
      test.equal options, '15.8kg', 15.8
      test.equal options, '-18.6%', -18.6
    it "should fail with sanitize option", ->
      options =
        type: 'float'
        sanitize: true
      test.fail options, 'gonow'
      test.fail options, 'one'
    it "should support round option", ->
      options =
        type: 'float'
        sanitize: true
        round: true
      test.equal options, 13.5, 14
      test.equal options, -9.49, -9
      test.equal options, '+18.6', 19
    it "should support decimal option", ->
      options =
        type: 'float'
        sanitize: true
        decimals: 1
      test.equal options, 13.5, 13.5
      test.equal options, -9.49, -9.5
      test.equal options, '+18.6', 18.6
    it "should support round (floor) option", ->
      options =
        type: 'float'
        sanitize: true
        round: 'floor'
      test.equal options, 13.5, 13
      test.equal options, -9.49, -10
      test.equal options, '+18.6', 18
    it "should support round (ceil) option", ->
      options =
        type: 'float'
        sanitize: true
        round: 'ceil'
      test.equal options, 13.5, 14
      test.equal options, -9.49, -9
      test.equal options, '+18.2', 19
    it "should support min option", ->
      options =
        type: 'float'
        min: -2
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
    it "should fail for min option", ->
      options =
        type: 'float'
        min: -2
      test.fail options, -8
    it "should support max option", ->
      options =
        type: 'float'
        max: 12
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
      test.equal options, 12, 12
    it "should fail for max option", ->
      options =
        type: 'float'
        max: -2
      test.fail options, 100
      test.fail options, -1

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'float'
        optional: true
        default: 5.4
        sanitize: true
        round: 2
        min: 2
        max: 20

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'float'
        optional: true
        default: 5.4
        sanitize: true
        round: 2
        min: 2
        max: 20
