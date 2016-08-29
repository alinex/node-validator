test = require '../../test'
### eslint-env node, mocha ###

#process.setMaxListeners 0


describe.only "Percent", ->

  schema = null
  beforeEach ->
    schema =
      type: 'percent'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 0.3
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match numbers", (cb) ->
      test.same schema, [18, 0.4, 0.02], cb

    it "should match string definitions", (cb) ->
      test.equal schema, [
        ['1800%', 18]
        ['40%', 0.4]
        ['-2%', -0.02]
        ['3.8%', 0.038]
      ], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, ['8 percent', null, [], (new Error '????'), {}, 'no%'], cb

  describe "option check", ->

    it "should support round option", (cb) ->
      schema.round = true
      test.equal schema, [
        [13.5, 14]
        [-48.9, -49]
        ['+18', 18]
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

    it "should support format option", (cb) ->
      schema.format = '0.0%'
      test.equal schema, [[0.2349, '23.5%']], cb

    it "should support local format option", (cb) ->
      schema.format = '0.0'
      schema.locale = 'de'
      test.equal schema, [[0.2349, '0,2']], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'percent'
        optional: true
        default: 0.5
        round: true
        decimals: 2
        min: 0.2
        max: 2
        format: '0.0'
        locale: 'de'
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'percent'
        optional: true
        default: 0.5
        round: true
        decimals: 2
        min: 0.2
        max: 2
        format: '0.0'
        locale: 'de'
      , cb
