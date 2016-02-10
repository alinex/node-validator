test = require '../../test'
### eslint-env node, mocha ###

moment = require 'moment'

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

  describe "helper", ->

    it "should format dates", (cb) ->
      context =
        date: new Date('1974-01-23')
      test.function schema, [
        ['{{dateFormat date "LL"}}', context, 'January 23, 1974']
      ], cb

    it "should format dates intl", (cb) ->
      context =
        date: new Date('1974-01-23')
      oldLocale = moment.locale()
      moment.locale 'de'
      test.function schema, [
        ['{{dateFormat date "LL"}}', context, '23. Januar 1974']
      ], ->
        moment.locale oldLocale
        cb()

    it "should join arrays", (cb) ->
      context =
        list: [1, 2, 3]
      test.function schema, [
        ['{{join list}}', context, '1 2 3']
        ['{{join list ", "}}', context, '1, 2, 3']
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb
