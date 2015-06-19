require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'

describe "Interval", ->

  schema = null
  beforeEach ->
    schema =
      type: 'interval'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 18
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match numbers", (cb) ->
      test.same schema, [18, 0, 11837], cb

    it "should match string definitions", (cb) ->
      test.equal schema, [
        ['12ms', 12]
        ['1s', 1000]
        ['1m', 60000]
        ['+18.6s', 18600]
      ], cb

    it "should match multiple unit string definitions", (cb) ->
      test.equal schema, [
        ['1s 12ms', 1012]
      ], cb

    it "should match time strings", (cb) ->
      test.equal schema, [
        ['1:02', 3720000]
        ['01:02', 3720000]
        ['1:2', 3720000]
        ['01:02:30', 3750000]
      ], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, ['hello', null, [], (new Error '????'), {}], cb

  describe "option check", ->

    it "should support unit option", (cb) ->
      schema.unit = 's'
      test.equal schema, [
        ['1600ms', 1.6]
        ['+18.6s', 18.6]
      ], ->
        schema.unit = 'm'
        test.equal schema, [
          ['600s', 10]
        ], ->
          schema.unit = 'h'
          test.equal schema, [
            ['7200s', 2]
          ], ->
            schema.unit = 'd'
            test.equal schema, [
              ['48h', 2]
            ], cb

    it "should support round option", (cb) ->
      schema.round = true
      test.equal schema, [
        [13.5, 14]
        [-9.489, -9]
        ['+18.6', 19]
      ], cb

    it "should support decimal option", (cb) ->
      schema.decimals = 1
      test.equal schema, [
        [13.5, 13.5]
        [-9.49, -9.5]
        ['+18.6', 18.6]
      ], cb

    it "should support round (floor) option", (cb) ->
      schema.round = 'floor'
      schema.decimals = 0
      test.equal schema, [
        [13.5, 13]
        [-9.49, -10]
        ['+18.6', 18]
      ], cb

    it "should support round (ceil) option", (cb) ->
      schema.round = 'ceil'
      schema.decimals = 0
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

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'interval'
        optional: true
        default: 5
        unit: 's'
        round: 'floor'
        decimals: 2
        min: 2
        max: 20
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'interval'
        optional: true
        default: 5
        unit: 's'
        round: 'floor'
        decimals: 2
        min: 2
        max: 20
      , cb
