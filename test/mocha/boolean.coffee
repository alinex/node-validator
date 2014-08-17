require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "Boolean", ->

  options = null

  beforeEach ->
    options =
      type: 'boolean'

  describe "sync check", ->

    it "should match real booleans", ->
      test.true options, true
      test.false options, false
    it "should be false on undefined", ->
      test.false options, null
      test.false options, undefined
    it "should match numbers", ->
      test.true options, 1
      test.false options, 0
      test.true options, 1.0
      test.false options, 0x0000
    it "should match strings", ->
      test.true options, 'true'
      test.false options, 'false'
      test.true options, 'on'
      test.false options, 'off'
      test.true options, 'yes'
      test.false options, 'no'
      test.true options, 'TRUE'
      test.false options, 'FALSE'
      test.true options, 'On'
      test.false options, 'Off'
      test.true options, 'Yes'
      test.false options, 'No'
    it "should fail on other strings", ->
      test.fail options, 'Hello'
      test.fail options, 'Nobody'
      test.fail options, 'o'
    it "should fail on other numbers", ->
      test.fail options, 3
      test.fail options, -1
      test.fail options, 0.1
    it "should fail on other types", ->
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}

  describe "async check", ->

    it "should match real booleans", (cb) ->
      async.series [
        (cb) -> test.true options, true, cb
        (cb) -> test.false options, false, cb
      ], cb
    it "should be false on undefined", (cb) ->
      async.series [
        (cb) -> test.false options, null, cb
        (cb) -> test.false options, undefined, cb
      ], cb
    it "should match numbers", (cb) ->
      async.series [
        (cb) -> test.true options, 1, cb
        (cb) -> test.false options, 0, cb
        (cb) -> test.true options, 1.0, cb
        (cb) -> test.false options, 0x0000, cb
      ], cb
    it "should match strings", (cb) ->
      async.series [
        (cb) -> test.true options, 'true', cb
        (cb) -> test.false options, 'false', cb
        (cb) -> test.true options, 'on', cb
        (cb) -> test.false options, 'off', cb
        (cb) -> test.true options, 'yes', cb
        (cb) -> test.false options, 'no', cb
        (cb) -> test.true options, 'TRUE', cb
        (cb) -> test.false options, 'FALSE', cb
        (cb) -> test.true options, 'On', cb
        (cb) -> test.false options, 'Off', cb
        (cb) -> test.true options, 'Yes', cb
        (cb) -> test.false options, 'No', cb
      ], cb
    it "should fail on other strings", (cb) ->
      async.series [
        (cb) -> test.fail options, 'Hello', cb
        (cb) -> test.fail options, 'Nobody', cb
        (cb) -> test.fail options, 'o', cb
      ], cb
    it "should fail on other numbers", (cb) ->
      async.series [
        (cb) -> test.fail options, 3, cb
        (cb) -> test.fail options, -1, cb
        (cb) -> test.fail options, 0.1, cb
      ], cb
    it "should fail on other types", (cb) ->
      async.series [
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, (new Error '????'), cb
        (cb) -> test.fail options, {}, cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options

