require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'

describe "Integer", ->

  schema = null
  beforeEach ->
    schema =
      type: 'integer'

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

    it "should match integer objects", (cb) ->
      test.same schema, [1, -12, 2678], cb

    it "should fail on other objects", (cb) ->
      test.fail schema, [15.3, '', null, [], (new Error '????'), {}], cb

    it "should support strings", (cb) ->
      test.equal schema, [
        ['1', 1]
        ['-16', -16]
      ], ->
        test.fail schema, ['1g'], cb

  describe "option check", ->

    it "should support sanitize option", (cb) ->
      schema.sanitize = true
      test.equal schema, [
        ['go4now', 4]
        ['15kg', 15]
        ['-18%', -18]
      ], ->
        test.fail schema, ['gonow', 'one'], cb

    it "should support round option", (cb) ->
      schema.round = true
      test.equal schema, [
        [13.5, 14]
        [-9.49, -9]
        ['+18.6', 19]
      ], cb

    it "should support round (floor) option", (cb) ->
      schema.round = 'floor'
      test.equal schema, [
        [13.5, 13]
        [-9.49, -10]
        ['+18.6', 18]
      ], cb

    it "should support round (ceil) option", (cb) ->
      schema.round = 'ceil'
      test.equal schema, [
        [13.5, 14]
        [-9.49, -9]
        ['+18.6', 19]
      ], cb

    it "should support min option", (cb) ->
      schema.min = -2
      test.same schema, [6, 0, -2], ->
        test.fail schema, [-8], cb

    it "should support max option", (cb) ->
      schema.max = 12
      test.same schema, [6, 0, -2, 12], ->
        schema.max = -2
        test.fail schema, [100, -1], cb

    it "should support type option", (cb) ->
      schema.inttype = 'byte'
      test.same schema, [6, -128, 127], ->
        test.fail schema, [128, -129], cb

    it "should support unsigned option", (cb) ->
      schema.inttype = 'byte'
      schema.unsigned = true
      test.same schema, [0, 254], ->
        test.fail schema, [256, -1], cb

  describe "unit checks", ->

    it "should parse meters", (cb) ->
      schema.unit = 'm'
      schema.round = 'ceil'
      test.equal schema, [
        [100, 100]
        ['100m', 100]
        ['100 m', 100]
        ['1km', 1000]
        ['100cm', 1]
        ['10000mm', 10]
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.describe schema

    it "should give complete description", ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'integer'
        optional: true
        default: 5
        sanitize: true
        round: 'floor'
        inttype: 'byte'
        unsigned: true
        min: -6
        max: 20

  describe.skip "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck schema

    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'integer'
        optional: true
        default: 5
        sanitize: true
        round: 'floor'
        inttype: 'byte'
        unsigned: true
        min: 2
        max: 20
