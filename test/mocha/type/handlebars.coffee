chai = require 'chai'
expect = chai.expect

async = require 'alinex-async'
test = require '../../test'

describe "Handlebars", ->

  schema = null
  beforeEach ->
    schema =
      type: 'handlebars'

  describe "base check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 'name'
      test.function schema, [
        [null, null, 'name']
        [undefined, null, 'name']
      ], cb

  describe "simple check", ->

    it "should match normal string", (cb) ->
      test.function schema, [
        ['hello', null, 'hello']
      ], cb

    it "should compile handlebars", (cb) ->
      test.function schema, [
        ['hello {{name}}', {name: 'alex'}, 'hello alex']
      ], cb

    it "should fail on other objects", (cb) ->
      test.fail schema, [null, [], (new Error '????'), {}], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb
