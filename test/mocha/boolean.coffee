require('alinex-error').install()
async = require 'async'

test = require '../test'

describe.only "Boolean", ->

  options = null

  beforeEach ->
    options =
      type: 'boolean'

  describe "sync check", ->

    it "should match real booleans", ->
      test.true options, true
      test.false options, false
    it "should match numbers", ->
      test.true options, 1
      test.false options, 0
      test.true options, 1.0
      test.false options, 0x0000
    it "should match strings", ->
      test.true options, 'true'
      test.false options, 'false'
      test.true options, '1'
      test.false options, '0'
      test.true options, 'on'
      test.false options, 'off'
      test.true options, 'yes'
      test.false options, 'no'
    it "should match uppercase", ->
      test.true options, 'True'
      test.false options, 'False'
      test.true options, 'ON'
      test.false options, 'OFF'
    it "should fail on undefined", ->
      test.fail options, null
      test.fail options, undefined
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

  describe "base check", ->

    it "should support optional option", ->
      options.optional = true
      test.false options, null
      test.false options, undefined
    it "should support default option", ->
      options.optional = true
      options.default = true
      test.true options, null
      test.true options, undefined

  describe "description", ->

    it "should give simple description", ->
      test.desc options

