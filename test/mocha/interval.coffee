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

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'interval'
        optional: true
        default: 5
        unit: 's'
        round: 'floor'
        min: 2
        max: 20

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'interval'
        optional: true
        default: 5
        unit: 's'
        round: 'floor'
        min: 2
        max: 20
