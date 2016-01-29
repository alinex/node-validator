test = require '../../test'
### eslint-env node, mocha ###

describe "Float", ->

  schema = null
  beforeEach ->
    schema =
      type: 'float'

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

    it "should match float objects", (cb) ->
      test.same schema, [1.0, -12.3, 2678.999, 10], cb

    it "should fail on other objects", (cb) ->
      test.fail schema, ['', null, [], (new Error '????'), {}], cb

  describe "options check", ->

    it "should support sanitize option", (cb) ->
      schema.sanitize = true
      test.equal schema, [
        ['go4now', 4]
        ['15.8kg', 15.8]
        ['-18.6%', -18.6]
      ], ->
        test.fail schema, ['gonow', 'one'], cb

    it "should support round option", (cb) ->
      schema.round = true
      test.equal schema, [
        [13.5, 14]
        [-9.49, -9]
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

  describe "unit checks", ->

    it "should parse meters", (cb) ->
      schema.unit = 'm'
      test.equal schema, [
        [100.6, 100.6]
        ['100.6m', 100.6]
        ['100.6 m', 100.6]
        ['1.2km', 1200]
        ['106cm', 1.06]
        ['10600mm', 10.6]
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'float'
        optional: true
        default: 5.4
        sanitize: true
        round: true
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
        type: 'float'
        optional: true
        default: 5.4
        sanitize: true
        round: true
        decimals: 2
        min: 2
        max: 20
      , cb
