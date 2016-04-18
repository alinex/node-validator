test = require '../../test'
### eslint-env node, mocha ###

moment = require 'moment'

describe.only "Handlebars", ->

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

  describe "comparison helper", ->

    it "should allow is blocks", (cb) ->
      test.function schema, [
        # is
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: true}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: 'd'}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: 1}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: false}, ' 2 ']
        ['{{#is y}} 1 {{else}} 2 {{/is}}', {x: true}, ' 2 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: ''}, ' 2 ']
        # equal
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 1}, ' 1 ']
        ['{{#is x "==" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 1}, ' 1 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 2}, ' 2 ']
        ['{{#is x "==" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 2}, ' 2 ']
        ['{{#is x "not" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 1}, ' 2 ']
        ['{{#is x "!=" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 1}, ' 2 ']
        ['{{#is x "not" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 2}, ' 1 ']
        ['{{#is x "!=" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 2}, ' 1 ']
        # numbers
        ['{{#is x ">" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: 1}, ' 1 ']
        ['{{#is x ">=" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: 2}, ' 1 ']
        ['{{#is x "<" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: 3}, ' 1 ']
        ['{{#is x "<=" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: 2}, ' 1 ']
        ['{{#is x ">" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 2}, ' 2 ']
        ['{{#is x ">=" y}} 1 {{else}} 2 {{/is}}', {x: 1, y: 2}, ' 2 ']
        ['{{#is x "<" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: 2}, ' 2 ']
        ['{{#is x "<=" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: 1}, ' 2 ']
        # in
        ['{{#is x "in" y}} 1 {{else}} 2 {{/is}}', {x: '2', y: '1,2,3,4'}, ' 1 ']
        ['{{#is x "in" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: [1, 2, 3, 4]}, ' 1 ']
        ['{{#is x "in" y}} 1 {{else}} 2 {{/is}}', {x: '6', y: '1,2,3,4'}, ' 2 ']
        ['{{#is x "in" y}} 1 {{else}} 2 {{/is}}', {x: 6, y: [1, 2, 3, 4]}, ' 2 ']
        ['{{#is x "!in" y}} 1 {{else}} 2 {{/is}}', {x: '2', y: '1,2,3,4'}, ' 2 ']
        ['{{#is x "!in" y}} 1 {{else}} 2 {{/is}}', {x: 2, y: [1, 2, 3, 4]}, ' 2 ']
        ['{{#is x "!in" y}} 1 {{else}} 2 {{/is}}', {x: '6', y: '1,2,3,4'}, ' 1 ']
        ['{{#is x "!in" y}} 1 {{else}} 2 {{/is}}', {x: 6, y: [1, 2, 3, 4]}, ' 1 ']
      ], cb

    it "should allow is blocks (on array/object)", (cb) ->
      test.function schema, [
        # array is
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: [1]}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: [9]}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: [9, 2]}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: []}, ' 2 ']
        # array equal
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: [1], y: 1}, ' 1 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: [9], y: 1}, ' 1 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: [9, 2], y: 2}, ' 1 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: [], y: 1}, ' 2 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: [9, 2], y: 1}, ' 2 ']
        # object is
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: {a: 1}}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: {a: 1, b: 2}}, ' 1 ']
        ['{{#is x}} 1 {{else}} 2 {{/is}}', {x: {}}, ' 2 ']
        # object equal
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: {a: 1}, y: 1}, ' 1 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: {a: 2}, y: 1}, ' 1 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: {a: 1, b: 2}, y: 2}, ' 1 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: {}, y: 1}, ' 2 ']
        ['{{#is x y}} 1 {{else}} 2 {{/is}}', {x: {a: 1, b: 2}, y: 1}, ' 2 ']
      ], cb

  describe "array helper", ->

  describe "object helper", ->

  describe "string helper", ->

    it "should lowercase", (cb) ->
      test.function schema, [
        ['{{lowercase "THIS SHOULD BE LOWERCASE"}}', null, 'this should be lowercase']
      ], cb

    it "should uppercase", (cb) ->
      test.function schema, [
        ['{{uppercase "this should be lowercase"}}', null, 'THIS SHOULD BE LOWERCASE']
      ], cb

    it "should capitalize first", (cb) ->
      test.function schema, [
        ['{{capitalizeFirst "this should be lowercase"}}', null, 'This should be lowercase']
      ], cb

    it "should capitallize each", (cb) ->
      test.function schema, [
        ['{{capitalizeEach "this should be lowercase"}}', null, 'This Should Be Lowercase']
      ], cb

    it "should shorten text", (cb) ->
      test.function schema, [
        ['{{shorten "this should be lowercase" 18}}', null, 'this should be...']
      ], cb

  describe "date helper", ->

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
        ['{{#dateFormat "LL"}}1974-01-23{{/dateFormat}}', context, '23. Januar 1974']
      ], ->
        moment.locale oldLocale
        cb()

    it "should add date interval", (cb) ->
      context =
        date: new Date('1974-01-23')
      test.function schema, [
        ['{{#dateFormat "LL"}}{{dateAdd date 1 "month"}}{{/dateFormat}}',
        context, 'February 23, 1974']
        ['{{#dateFormat "LL"}}{{dateAdd date -1 "month"}}{{/dateFormat}}',
        context, 'December 23, 1973']
        ['{{#dateFormat "LL"}}{{#dateAdd 1 "month"}}1974-01-23{{/dateAdd}}{{/dateFormat}}',
        context, 'February 23, 1974']
      ], cb

    it "should allow unit format", (cb) ->
      test.function schema, [
        ['{{unitFormat x}}', {x: '1234567mm'}, '1.23 km']
        ['{{unitFormat x "mm"}}', {x: 1234567}, '1.23 km']
        ['{{unitFormat x "mm" "km"}}', {x: 1234567}, '1.23 km']
        ['{{unitFormat x "mm" "m"}}', {x: 1234567}, '1230 m']
        ['{{unitFormat x "mm" "m" 4}}', {x: 1234567}, '1235 m']
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb
