require('alinex-error').install()
async = require 'async'

test = require '../test'

process.setMaxListeners 0

describe "Percent", ->

  options = null

  beforeEach ->
    options =
      type: 'percent'

  describe "sync check", ->

    it "should match number objects", ->
      test.equal options, 18, 18
      test.equal options, 0.4, 0.4
      test.equal options, -0.02, -0.02
    it "should match string definition", ->
      test.equal options, '1800%', 18
      test.equal options, '40%', 0.4
      test.equal options, '-2%', -0.02
      test.equal options, '3.8%', 0.038
    it "should fail on other objects", ->
      test.fail options, 'hello'
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'percent'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support round option", ->
      options =
        type: 'percent'
        round: 1
      test.equal options, 13.44, 13.4
      test.equal options, '+18.56', 18.6
    it "should support min option", ->
      options =
        type: 'percent'
        min: 0
      test.equal options, 0.06, 0.06
      test.equal options, 0, 0
    it "should fail for min option", ->
      options =
        type: 'percent'
        min: 0
      test.fail options, -8
    it "should support max option", ->
      options =
        type: 'percent'
        max: 1
      test.equal options, 1, 1
      test.equal options, '100%', 1
    it "should fail for max option", ->
      options =
        type: 'percent'
        max: 1
      test.fail options, 10
      test.fail options, '110%'

  describe "async check", ->

    it "should match number objects", (cb) ->
      async.series [
        (cb) -> test.equal options, 18, 18, cb
        (cb) -> test.equal options, 0.4, 0.4, cb
        (cb) -> test.equal options, -0.02, -0.02, cb
      ], cb
    it "should match string definition", (cb) ->
      async.series [
        (cb) -> test.equal options, '1800%', 18, cb
        (cb) -> test.equal options, '40%', 0.4, cb
        (cb) -> test.equal options, '-2%', -0.02, cb
        (cb) -> test.equal options, '3.8%', 0.038, cb
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
        type: 'percent'
        optional: true
      async.series [
        (cb) -> test.equal options, null, null, cb
        (cb) -> test.equal options, undefined, null, cb
      ], cb
    it "should support round option", (cb) ->
      options =
        type: 'percent'
        round: 1
      async.series [
        (cb) -> test.equal options, 13.44, 13.4, cb
        (cb) -> test.equal options, '+18.56', 18.6, cb
      ], cb
    it "should support min option", (cb) ->
      options =
        type: 'percent'
        min: 0
      async.series [
        (cb) -> test.equal options, 0.06, 0.06, cb
        (cb) -> test.equal options, 0, 0, cb
      ], cb
    it "should fail for min option", (cb) ->
      options =
        type: 'percent'
        min: 0
      async.series [
        (cb) -> test.fail options, -8, cb
      ], cb
    it "should support max option", (cb) ->
      options =
        type: 'percent'
        max: 1
      async.series [
        (cb) -> test.equal options, 1, 1, cb
        (cb) -> test.equal options, '100%', 1, cb
      ], cb
    it "should fail for max option", (cb) ->
      options =
        type: 'percent'
        max: 1
      async.series [
        (cb) -> test.fail options, 10, cb
        (cb) -> test.fail options, '110%', cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options
