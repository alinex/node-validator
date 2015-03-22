chai = require 'chai'
expect = chai.expect

require('alinex-error').install()
async = require 'alinex-async'
test = require '../test'
validator = require '../../lib/index'

describe "Handlebars", ->

  options = null

  beforeEach ->
    options =
      type: 'handlebars'

  describe "sync check", ->

    it "should match normal string", ->
      value = validator.check('test', options, 'hello')
      expect(value).to.be.a 'function'
      expect(value {name: 'alex'}).to.equal 'hello'

    it "should compile handlebars", ->
      value = validator.check('test', options, 'hello {{name}}')
      expect(value).to.be.a 'function'
      expect(value {name: 'alex'}).to.equal 'hello alex'

  describe "description", ->

    it "should give simple description", ->
      test.desc options

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
