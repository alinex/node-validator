require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "Integer", ->

  options = null

  beforeEach ->
    options =
      type: 'integer'

  describe "sync check", ->

    it "should match integer objects", ->
      test.equal options, 1, 1
      test.equal options, -12, -12
      test.equal options, '3678', 3678
    it "should fail on other objects", ->
      test.fail options, 15.3
      test.fail options, ''
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'integer'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support sanitize option", ->
      options =
        type: 'integer'
        sanitize: true
      test.equal options, 'go4now', 4
      test.equal options, '15kg', 15
      test.equal options, '-18.6%', -18
    it "should fail with sanitize option", ->
      options =
        type: 'integer'
        sanitize: true
      test.fail options, 'gonow'
      test.fail options, 'one'
    it "should support round option", ->
      options =
        type: 'integer'
        sanitize: true
        round: true
      test.equal options, 13.5, 14
      test.equal options, -9.49, -9
      test.equal options, '+18.6', 19
    it "should support round (floor) option", ->
      options =
        type: 'integer'
        sanitize: true
        round: 'floor'
      test.equal options, 13.5, 13
      test.equal options, -9.49, -10
      test.equal options, '+18.6', 18
    it "should support round (ceil) option", ->
      options =
        type: 'integer'
        sanitize: true
        round: 'ceil'
      test.equal options, 13.5, 14
      test.equal options, -9.49, -9
      test.equal options, '+18.2', 19
    it "should support min option", ->
      options =
        type: 'integer'
        min: -2
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
    it "should fail for min option", ->
      options =
        type: 'integer'
        min: -2
      test.fail options, -8
    it "should support max option", ->
      options =
        type: 'integer'
        max: 12
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
      test.equal options, 12, 12
    it "should fail for max option", ->
      options =
        type: 'integer'
        max: -2
      test.fail options, 100
      test.fail options, -1
    it "should support type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
      test.equal options, 6, 6
      test.equal options, -128, -128
      test.equal options, 127, 127
    it "should fail for type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
      test.fail options, 128
      test.fail options, -129
    it "should support type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
        unsigned: true
      test.equal options, 254, 254
      test.equal options, 0, 0
    it "should fail for type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
        unsigned: true
      test.fail options, 256
      test.fail options, -1

  describe "async check", ->

    it "should match integer objects", (cb) ->
      async.series [
        (cb) -> test.equal options, 1, 1, cb
        (cb) -> test.equal options, -12, -12, cb
        (cb) -> test.equal options, '3678', 3678, cb
      ], cb
    it "should fail on other objects", (cb) ->
      async.series [
        (cb) -> test.fail options, 15.3, cb
        (cb) -> test.fail options, '', cb
        (cb) -> test.fail options, null, cb
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, (new Error '????'), cb
        (cb) -> test.fail options, {}, cb
      ], cb
    it "should support optional option", (cb) ->
      options =
        type: 'integer'
        optional: true
      async.series [
        (cb) -> test.equal options, null, null, cb
        (cb) -> test.equal options, undefined, null, cb
      ], cb
    it "should support sanitize option", (cb) ->
      options =
        type: 'integer'
        sanitize: true
      async.series [
        (cb) -> test.equal options, 'go4now', 4, cb
        (cb) -> test.equal options, '15kg', 15, cb
        (cb) -> test.equal options, '-18.6%', -18, cb
      ], cb
    it "should fail with sanitize option", (cb) ->
      options =
        type: 'integer'
        sanitize: true
      async.series [
        (cb) -> test.fail options, 'gonow', cb
        (cb) -> test.fail options, 'one', cb
      ], cb
    it "should support round option", (cb) ->
      options =
        type: 'integer'
        sanitize: true
        round: true
      async.series [
        (cb) -> test.equal options, 13.5, 14, cb
        (cb) -> test.equal options, -9.49, -9, cb
        (cb) -> test.equal options, '+18.6', 19, cb
      ], cb
    it "should support round (floor) option", (cb) ->
      options =
        type: 'integer'
        sanitize: true
        round: 'floor'
      async.series [
        (cb) -> test.equal options, 13.5, 13, cb
        (cb) -> test.equal options, -9.49, -10, cb
        (cb) -> test.equal options, '+18.6', 18, cb
      ], cb
    it "should support round (ceil) option", (cb) ->
      options =
        type: 'integer'
        sanitize: true
        round: 'ceil'
      async.series [
        (cb) -> test.equal options, 13.5, 14, cb
        (cb) -> test.equal options, -9.49, -9, cb
        (cb) -> test.equal options, '+18.2', 19, cb
      ], cb
    it "should support min option", (cb) ->
      options =
        type: 'integer'
        min: -2
      async.series [
        (cb) -> test.equal options, 6, 6, cb
        (cb) -> test.equal options, 0, 0, cb
        (cb) -> test.equal options, -2, -2, cb
      ], cb
    it "should fail for min option", (cb) ->
      options =
        type: 'integer'
        min: -2
      async.series [
        (cb) -> test.fail options, -8, cb
      ], cb
    it "should support max option", (cb) ->
      options =
        type: 'integer'
        max: 12
      async.series [
        (cb) -> test.equal options, 6, 6, cb
        (cb) -> test.equal options, 0, 0, cb
        (cb) -> test.equal options, -2, -2, cb
        (cb) -> test.equal options, 12, 12, cb
      ], cb
    it "should fail for max option", (cb) ->
      options =
        type: 'integer'
        max: -2
      async.series [
        (cb) -> test.fail options, 100, cb
        (cb) -> test.fail options, -1, cb
      ], cb
    it "should support type option", (cb) ->
      options =
        type: 'integer'
        inttype: 'byte'
      async.series [
        (cb) -> test.equal options, 6, 6, cb
        (cb) -> test.equal options, -128, -128, cb
        (cb) -> test.equal options, 127, 127, cb
      ], cb
    it "should fail for type option", (cb) ->
      options =
        type: 'integer'
        inttype: 'byte'
      async.series [
        (cb) -> test.fail options, 128, cb
        (cb) -> test.fail options, -129, cb
      ], cb
    it "should support type option", (cb) ->
      options =
        type: 'integer'
        inttype: 'byte'
        unsigned: true
      async.series [
        (cb) -> test.equal options, 254, 254, cb
        (cb) -> test.equal options, 0, 0, cb
      ], cb
    it "should fail for type option", (cb) ->
      options =
        type: 'integer'
        inttype: 'byte'
        unsigned: true
      async.series [
        (cb) -> test.fail options, 256, cb
        (cb) -> test.fail options, -1, cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options
