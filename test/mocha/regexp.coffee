require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

describe "RegExp", ->

  options = null

  beforeEach ->
    options =
      type: 'regexp'

  describe "sync check", ->

    it "should match regexp instance", ->
      test.instance options, /a/, RegExp
      test.instance options, /[a-z]/g, RegExp
    it "should match string definition", ->
      test.instance options, '/a/', RegExp
      test.instance options, '/[a-z]/g', RegExp
    it "should fail on other objects", ->
      test.fail options, 'hello'
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should fail on invalid expression", ->
      test.fail options, '/hello'
      test.fail options, '/he(llo/'

  describe "description", ->

    it "should give simple description", ->
      test.desc options

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
