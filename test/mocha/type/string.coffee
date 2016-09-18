test = require '../../test'
### eslint-env node, mocha ###

describe "String", ->

  schema = null
  beforeEach ->
    schema =
      type: 'string'

  describe "base check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = '1'
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match string objects", (cb) ->
      test.same schema, ['hello', '1', ''], cb

    it "should fail on other objects", (cb) ->
      test.fail schema, [1, null, [], (new Error '????'), {}], cb

  describe "options check", ->

    it "should support makeString option", (cb) ->
      schema.makeString = true
      test.equal schema, [
        [4, '4']
        [(new Error 'test'), 'Error: test']
      ], cb

    it "should support trim option", (cb) ->
      schema.trim = true
      test.equal schema, [
        ['  hello', 'hello']
        ['hello  ', 'hello']
        ['  hello  ', 'hello']
        ['', '']
      ], cb

    it "should support crop option", (cb) ->
      schema.crop = 8
      test.equal schema, [
        ['123456789', '12345678']
        ['123', '123']
      ], cb

    it "should support replace option", (cb) ->
      schema.replace = [/a/g, 'o']
      test.equal schema, [
        ['great', 'greot']
        ['aligator', 'oligotor']
      ], cb

    it "should support multi replace option", (cb) ->
      schema.replace = [
        [/a/g, 'o']
        [/m/, 'n']
      ]
      test.equal schema, [
        ['great', 'greot']
        ['aligator', 'oligotor']
        ['meet', 'neet']
        ['meet me', 'neet me']
        ['great meal', 'greot neol']
      ], cb

    it "should strip control characters", (cb) ->
      test.equal schema, [
        ["123\x00456789", "123456789"]
      ], cb

    it "should support allowControls option", (cb) ->
      schema.allowControls = true
      test.equal schema, [
        ["123\x00456789", "123\x00456789"]
      ], cb

    it "should support stripTags option", (cb) ->
      schema.stripTags = true
      test.equal schema, [
        ["the <b>best</b>", "the best"]
      ], cb

    it "should support lowercase option", (cb) ->
      schema.lowerCase = true
      test.equal schema, [
        ["HELLo", "hello"]
      ], cb

    it "should support lowercase of first character", (cb) ->
      schema.lowerCase = 'first'
      test.equal schema, [
        ["HELLo", "hELLo"]
      ], cb

    it "should support uppercase option", (cb) ->
      schema.upperCase = true
      test.equal schema, [
        ["hello", "HELLO"]
      ], cb

    it "should support uppercase of first character", (cb) ->
      schema.upperCase = 'first'
      test.equal schema, [
        ["hello", "Hello"]
      ], cb

    it "should support minlength option", (cb) ->
      schema.minLength = 5
      test.same schema, ["hello", "hello to everybody"], ->
        test.fail schema, ["", "123"], cb

    it "should support maxlength option", (cb) ->
      schema.maxLength = 5
      test.same schema, ["", "123", "hello"], ->
        test.fail schema, ["hello to everybody"], cb

    it "should support values option", (cb) ->
      schema.values = ['one', 'two', 'three']
      test.same schema, schema.values, ->
        test.fail schema, ['nine', 'bananas'], cb

    it "should support values option with object", (cb) ->
      schema.values =
        one: 1
        two: 2
        three: 3
      test.same schema, ['one', 'two', 'three'], cb

    it "should support startsWith option", (cb) ->
      schema.startsWith = 'he'
      test.same schema, ['hello', 'hero'], ->
        test.fail schema, ['', 'ciao'], cb

    it "should support endsWith option", (cb) ->
      schema.endsWith = 'lo'
      test.same schema, ['hello'], ->
        test.fail schema, ['', 'ciao'], cb

    it "should support match option", (cb) ->
      schema.match = 'll'
      test.same schema, ['hello'], ->
        test.fail schema, ['ciao'], cb

    it "should support multi match option", (cb) ->
      schema.match = ['he', /ll/]
      test.same schema, ['hello'], ->
        test.fail schema, ['ciao', 'hero', 'call'], cb

    it "should support matchNot option", (cb) ->
      schema.matchNot = 'll'
      test.same schema, ['ciao'], ->
        test.fail schema, ['hello'], cb

    it "should support matchNot option with regexp", (cb) ->
      schema.matchNot = /ll/
      test.same schema, ['ciao'], ->
        test.fail schema, ['hello'], cb

    it "should support multi matchNot option", (cb) ->
      schema.matchNot = ['he', /ll/]
      test.same schema, ['ciao'], ->
        test.fail schema, ['hello'], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'string'
        optional: true
        default: 'nix'
        makeString: true
        allowControls: true
        stripTags: true
        lowerCase: true
        upperCase: 'first'
        replace: [['test', 'done'], ['name', 'alex']]
        trim: true
        crop: 50
        minLength: 5
        maxLength: 50
        values: ['Kopenhagen', 'Amsterdam', 'Hannover']
        startsWith: 'H'
        endsWith: 'r'
        match: /\w+/
        matchNot: /\d/
      , cb

    it "should give uppercase all lowercase first description", (cb) ->
      test.describe
        type: 'string'
        upperCase: true
        lowerCase: 'first'
      , cb


  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'string'
        optional: true
        default: 'nix'
        toString: true
        allowControls: true
        stripTags: true
        lowerCase: true
        upperCase: 'first'
        replace: [/test/, 'done']
        trim: true
        crop: 50
        minLength: 5
        maxLength: 50
        values: ['Kopenhagen', 'Amsterdam', 'Hannover']
        startsWith: 'H'
        endsWith: 'r'
        match: /\w+/
        matchNot: /\d/
      , cb
