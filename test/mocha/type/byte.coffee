async = require 'alinex-async'

test = require '../../test'

describe "Byte", ->

  schema = null
  beforeEach ->
    schema =
      type: 'byte'

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

    it "should match integers", (cb) ->
      test.same schema, [18, 0, 118371], cb

    it "should match string definitions", (cb) ->
      test.equal schema, [
        ['12', 12]
        ['100B', 100]
        ['100 B', 100]
      ], cb

    it "should match prefix definition", (cb) ->
      test.equal schema, [
        ['1kB', 1000]
        ['1KiB', 1024]
        ['1MB', 1000000]
        ['1MiB', 1024*1024]
        ['1GB', 1000000000]
        ['1GiB', 1024*1024*1024]
      ], cb

    it "should fail on other objects", (cb) ->
      test.fail schema, ['hello', null, [], (new Error '????'), {}], cb

  describe "derived bps", ->

    it "should match string definition", (cb) ->
      test.equal schema, [
        ['100bps', 100]
      ], cb

    it "should match prefix definition", (cb) ->
      test.equal schema, [
        ['1kbps', 1000]
        ['1Mbps', 1000000]
        ['1Gbps', 1000000000]
      ], cb

  describe "options check", ->

    it "should support unit option", (cb) ->
      schema.unit = 'kbps'
      test.equal schema, [
        ['1kbps', 1]
        ['1Mbps', 1000]
        ['1Gbps', 1000000]
      ], cb

    it "should support round option on base values", (cb) ->
      schema.round = true
      test.equal schema, [
        [13.5, 14]
        [9.49, 9]
        [+18.6, 19]
      ], cb

    it "should support round option on higher values", (cb) ->
      schema.round = true
      schema.unit = 'kbps'
      test.same schema, [13.5, 9.49, 9, +18.6], cb

    it "should support decimal option", (cb) ->
      schema.unit = 'kbps'
      schema.decimals = 1
      test.equal schema, [
        [13.5, 13.5]
        [9.49, 9.5]
        [+18.6, 18.6]
      ], cb

    it "should support round (floor) option", (cb) ->
      schema.unit = 'kbps'
      schema.round = 'floor'
      schema.decimals = 0
      test.equal schema, [
        [13.5, 13]
        [9.49, 9]
        [+18.6, 18]
      ], cb

    it "should support round (ceil) option", (cb) ->
      schema.unit = 'kbps'
      schema.round = 'ceil'
      schema.decimals = 0
      test.equal schema, [
        [13.5, 14]
        [9.49, 10]
        [+18.6, 19]
      ], cb

    it "should support min option", (cb) ->
      schema.min = 2
      test.same schema, [6, 10, 2], ->
        test.fail schema, [0, 1], cb

    it "should support max option", (cb) ->
      schema.max = 12
      test.same schema, [6, 0, 2, 12], ->
        schema.max = -2
        test.fail schema, [100, 13], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'byte'
        optional: true
        default: 5
        unit: 'kbps'
        round: 'ceil'
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
        type: 'byte'
        optional: true
        default: 5
        unit: 'kbps'
        round: 'ceil'
        decimals: 2
        min: 2
        max: 20
      , cb
