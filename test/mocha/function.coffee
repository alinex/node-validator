require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "Function", ->

  options = null

  beforeEach ->
    options =
      type: 'function'

  describe "sync check", ->

    it "should match functions", ->
      test.equal options, beforeEach, beforeEach
    it "should match classes", ->
      test.equal options, RegExp, RegExp
      test.equal options, Array, Array
    it "should fail on undefined", ->
      test.fail options, null
      test.fail options, undefined

  describe "base check", ->

    it "should support optional option", ->
      options.optional = true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support default option", ->
      options.optional = true
      options.default = RegExp
      test.equal options, null, RegExp

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        type: 'function'
        optional: true
        default: RegExp

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        type: 'function'
        optional: true
        default: RegExp
