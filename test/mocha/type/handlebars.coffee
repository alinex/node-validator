test = require '../../test'
### eslint-env node, mocha ###

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

  describe "intl", ->

    it "should replace numbers", (cb) ->
      context =
        num: 42000
        completed: 0.9
        price: 100.95
      test.function schema, [
        ['{{formatNumber num}}', context, '42,000']
        ['{{formatNumber completed style="percent"}}', context, '90%']
        ['{{formatNumber price style="currency" currency="USD"}}', context, '$100.95']
      ], cb

    it "should format relative dates", (cb) ->
      context =
        postDate: Date.now() - (1000 * 60 * 60 * 24)
        commentDate: Date.now() - (1000 * 60 * 60 * 2)
        meetingDate: Date.now() + (1000 * 60 * 51)
      test.function schema, [
        ['{{formatRelative postDate}}', context, 'yesterday']
        ['{{formatRelative commentDate}}', context, '2 hours ago']
        ['{{formatRelative meetingDate}}', context, 'in 1 hour']
      ], cb

    it "should format dates", (cb) ->
      context =
        date: new Date('1974-01-23')
      test.function schema, [
        ['{{formatDate date day="numeric" month="long" year="numeric"}}'
        context, 'January 23, 1974']
        ['{{formatDate date "short"}}', context, 'January 23, 1974']
        ], cb

    it.only "should format dates intl", (cb) ->
      context =
        date: new Date('1974-01-23')
      test.function2 schema, [
        ['{{formatDate date "short"}}'
          context,
            intl:
              locales: 'de-DE'
          , '23. Januar 1974']
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb
