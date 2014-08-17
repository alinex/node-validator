require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "Float", ->

  options = null

  beforeEach ->
    options =
      type: 'float'

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
        round: 1
      test.equal options, 13.5, 13.5
      test.equal options, -9.49, -9.5
      test.equal options, '+18.6', 18.6
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

  describe "async check", ->

    it "should match float objects", (cb) ->
      async.series [
        (cb) -> test.equal options, 1.0, 1, cb
        (cb) -> test.equal options, -12.3, -12.3, cb
        (cb) -> test.equal options, '3678.999', 3678.999, cb
        (cb) -> test.equal options, 10, 10, cb
      ], cb
    it "should fail on other objects", (cb) ->
      async.series [
        (cb) -> test.fail options, '', cb
        (cb) -> test.fail options, null, cb
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, (new Error '????'), cb
        (cb) -> test.fail options, {}, cb
      ], cb
    it "should support optional option", (cb) ->
      options =
        type: 'float'
        optional: true
      async.series [
        (cb) -> test.equal options, null, null, cb
        (cb) -> test.equal options, undefined, null, cb
      ], cb
    it "should support sanitize option", (cb) ->
      options =
        type: 'float'
        sanitize: true
      async.series [
        (cb) -> test.equal options, 'go4now', 4, cb
        (cb) -> test.equal options, '15.8kg', 15.8, cb
        (cb) -> test.equal options, '-18.6%', -18.6, cb
      ], cb
    it "should fail with sanitize option", (cb) ->
      options =
        type: 'float'
        sanitize: true
      async.series [
        (cb) -> test.fail options, 'gonow', cb
        (cb) -> test.fail options, 'one', cb
      ], cb
    it "should support round option", (cb) ->
      options =
        type: 'float'
        sanitize: true
        round: 1
      async.series [
        (cb) -> test.equal options, 13.5, 13.5, cb
        (cb) -> test.equal options, -9.49, -9.5, cb
        (cb) -> test.equal options, '+18.6', 18.6, cb
      ], cb
    it "should support min option", (cb) ->
      options =
        type: 'float'
        min: -2
      async.series [
        (cb) -> test.equal options, 6, 6, cb
        (cb) -> test.equal options, 0, 0, cb
        (cb) -> test.equal options, -2, -2, cb
      ], cb
    it "should fail for min option", (cb) ->
      options =
        type: 'float'
        min: -2
      async.series [
        (cb) -> test.fail options, -8, cb
      ], cb
    it "should support max option", (cb) ->
      options =
        type: 'float'
        max: 12
      async.series [
        (cb) -> test.equal options, 6, 6, cb
        (cb) -> test.equal options, 0, 0, cb
        (cb) -> test.equal options, -2, -2, cb
        (cb) -> test.equal options, 12, 12, cb
      ], cb
    it "should fail for max option", (cb) ->
      options =
        type: 'float'
        max: -2
      async.series [
        (cb) -> test.fail options, 100, cb
        (cb) -> test.fail options, -1, cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options

