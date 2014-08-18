require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "Interval", ->

  options = null

  beforeEach ->
    options =
      type: 'interval'

  describe "sync check", ->

    it "should match number objects", ->
      test.equal options, 18, 18
      test.equal options, 0, 0
      test.equal options, 118371, 118371
    it "should match string definition", ->
      test.equal options, '12ms', 12
      test.equal options, '1s', 1000
      test.equal options, '1m', 60000
      test.equal options, '+18.6s', 18600
    it "should match time definition", ->
      test.equal options, '1:02', 3720000
      test.equal options, '01:02', 3720000
      test.equal options, '1:2', 3720000
      test.equal options, '01:02:30', 3750000
    it "should fail on other objects", ->
      test.fail options, 'hello'
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'interval'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support unit option", ->
      options =
        type: 'interval'
        unit: 's'
      test.equal options, '1600ms', 1.6
      test.equal options, '+18.6s', 18.6
    it "should support round option", ->
      options =
        type: 'interval'
        unit: 's'
        round: true
      test.equal options, 13.5, 14
      test.equal options, '+18.6s', 19
    it "should support round (floor) option", ->
      options =
        type: 'interval'
        unit: 's'
        round: 'floor'
      test.equal options, 13.5, 13
      test.equal options, '+18.6s', 18
    it "should support round (ceil) option", ->
      options =
        type: 'interval'
        unit: 's'
        round: 'ceil'
      test.equal options, 13.5, 14
      test.equal options, '+18.2s', 19
    it "should support min option", ->
      options =
        type: 'interval'
        min: -2
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
    it "should fail for min option", ->
      options =
        type: 'interval'
        min: -2
      test.fail options, -8
    it "should support max option", ->
      options =
        type: 'interval'
        max: 12
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
      test.equal options, 12, 12
    it "should fail for max option", ->
      options =
        type: 'interval'
        max: -2
      test.fail options, 100
      test.fail options, -1

  describe "async check", ->

    it "should match number objects", (cb) ->
      async.series [
        (cb) -> test.equal options, 18, 18, cb
        (cb) -> test.equal options, 0, 0, cb
        (cb) -> test.equal options, 118371, 118371, cb
      ], cb
    it "should match string definition", (cb) ->
      async.series [
        (cb) -> test.equal options, '12ms', 12, cb
        (cb) -> test.equal options, '1s', 1000, cb
        (cb) -> test.equal options, '1m', 60000, cb
        (cb) -> test.equal options, '+18.6s', 18600, cb
      ], cb
    it "should fail on other objects", (cb) ->
      async.series [
        (cb) -> test.fail options, 'hello', cb
        (cb) -> test.fail options, null, cb
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, (new Error '????'), cb
        (cb) -> test.fail options, {}, cb
      ], cb
    it "should support optional option", (cb) ->
      options =
        type: 'interval'
        optional: true
      async.series [
        (cb) -> test.equal options, null, null, cb
        (cb) -> test.equal options, undefined, null, cb
      ], cb
    it "should support unit option", (cb) ->
      options =
        type: 'interval'
        unit: 's'
      async.series [
        (cb) -> test.equal options, '1600ms', 1.6, cb
        (cb) -> test.equal options, '+18.6s', 18.6, cb
      ], cb
    it "should support round option", (cb) ->
      options =
        type: 'interval'
        unit: 's'
        round: true
      async.series [
        (cb) -> test.equal options, 13.5, 14, cb
        (cb) -> test.equal options, '+18.6s', 19, cb
      ], cb
    it "should support round (floor) option", (cb) ->
      options =
        type: 'interval'
        unit: 's'
        round: 'floor'
      async.series [
        (cb) -> test.equal options, 13.5, 13, cb
        (cb) -> test.equal options, '+18.6s', 18, cb
      ], cb
    it "should support round (ceil) option", (cb) ->
      options =
        type: 'interval'
        unit: 's'
        round: 'ceil'
      async.series [
        (cb) -> test.equal options, 13.5, 14, cb
        (cb) -> test.equal options, '+18.2s', 19, cb
      ], cb
    it "should support min option", (cb) ->
      options =
        type: 'interval'
        min: -2
      async.series [
        (cb) -> test.equal options, 6, 6, cb
        (cb) -> test.equal options, 0, 0, cb
        (cb) -> test.equal options, -2, -2, cb
      ], cb
    it "should fail for min option", (cb) ->
      options =
        type: 'interval'
        min: -2
      async.series [
        (cb) -> test.fail options, -8, cb
      ], cb
    it "should support max option", (cb) ->
      options =
        type: 'interval'
        max: 12
      async.series [
        (cb) -> test.equal options, 6, 6, cb
        (cb) -> test.equal options, 0, 0, cb
        (cb) -> test.equal options, -2, -2, cb
        (cb) -> test.equal options, 12, 12, cb
      ], cb
    it "should fail for max option", (cb) ->
      options =
        type: 'interval'
        max: -2
      async.series [
        (cb) -> test.fail options, 100, cb
        (cb) -> test.fail options, -1, cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options
