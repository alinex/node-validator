require('alinex-error').install()
async = require 'async'

test = require '../test'

describe.only "String", ->

  options = null

  beforeEach ->
    options =
      type: 'string'

  describe "sync check", ->

    it "should match string objects", ->
      test.equal options, 'hello', 'hello'
      test.equal options, '1', '1'
      test.equal options, '', ''
    it "should fail on other objects", ->
      test.fail options, 1
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'string'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support default option", ->
      options =
        type: 'string'
        optional: true
        default: ''
      test.equal options, null, ''
      test.equal options, undefined, ''
    it "should support tostring option", ->
      options =
        type: 'string'
        tostring: true
      test.equal options, (new Error 'test'), 'Error: test'
    it "should support trim option", ->
      options =
        type: 'string'
        trim: true
      test.equal options, '  hello', 'hello'
      test.equal options, 'hello  ', 'hello'
      test.equal options, '  hello  ', 'hello'
      test.equal options, '', ''
    it "should support crop option", ->
      options =
        type: 'string'
        crop: 8
      test.equal options, '123456789', '12345678'
      test.equal options, '123', '123'
    it "should support replace option", ->
      options =
        type: 'string'
        replace: [/a/g, 'o']
      test.equal options, 'great', 'greot'
      test.equal options, 'aligator', 'oligotor'
    it "should support multi replace option", ->
      options =
        type: 'string'
        replace: [
          [/a/g, 'o']
          ['m', 'n']
        ]
      test.equal options, 'great', 'greot'
      test.equal options, 'aligator', 'oligotor'
      test.equal options, 'meet', 'neet'
      test.equal options, 'meet me', 'neet me'
      test.equal options, 'great meal', 'greot neol'
    it "should strip control characters", ->
      test.equal options, "123\x00456789", "123456789"
    it "should support allowControls option", ->
      options =
        type: 'string'
        allowControls: true
      test.equal options, "123\x00456789", "123\x00456789"
    it "should support stripTags option", ->
      options =
        type: 'string'
        stripTags: true
      test.equal options, "the <b>best</b>", "the best"
    it "should support lowercase option", ->
      options =
        type: 'string'
        lowerCase: true
      test.equal options, "HELLo", "hello"
    it "should support lowercase of first character", ->
      options =
        type: 'string'
        lowerCase: 'first'
      test.equal options, "HELLo", "hELLo"
    it "should support uppercase option", ->
      options =
        type: 'string'
        upperCase: true
      test.equal options, "hello", "HELLO"
    it "should support uppercase of first character", ->
      options =
        type: 'string'
        upperCase: 'first'
      test.equal options, "hello", "Hello"
    it "should support minlength option", ->
      options =
        type: 'string'
        minLength: 5
      test.equal options, "hello", "hello"
      test.equal options, "hello to everybody", "hello to everybody"
    it "should fail for minlength on too long strings", ->
      options =
        type: 'string'
        minLength: 5
      test.fail options, ""
      test.fail options, "123"
    it "should support maxlength option", ->
      options =
        type: 'string'
        maxLength: 5
      test.equal options, "", ""
      test.equal options, "123", "123"
      test.equal options, "hello", "hello"
    it "should fail for maxlength on too long strings", ->
      options =
        type: 'string'
        maxLength: 4
      test.fail options, "hello"
      test.fail options, "hello to everybody"
    it "should support values option", ->
      options =
        type: 'string'
        values: ['one', 'two', 'three']
      test.equal options, "one", "one"
    it "should fail for values option", ->
      options =
        type: 'string'
        values: ['one', 'two', 'three']
      test.fail options, ""
      test.fail options, "nine"
      test.fail options, "bananas"
    it "should support startsWith option", ->
      options =
        type: 'string'
        startsWith: 'he'
      test.equal options, "hello", "hello"
      test.equal options, "hero", "hero"
    it "should fail for startsWith option", ->
      options =
        type: 'string'
        startsWith: 'he'
      test.fail options, "ciao"
      test.fail options, ""
    it "should support endsWith option", ->
      options =
        type: 'string'
        endsWith: 'lo'
      test.equal options, "hello", "hello"
    it "should fail for endsWith option", ->
      options =
        type: 'string'
        endsWith: 'he'
      test.fail options, "ciao"
      test.fail options, ""
    it "should support match option", ->
      options =
        type: 'string'
        match: 'll'
      test.equal options, "hello", "hello"
    it "should support multi match option", ->
      options =
        type: 'string'
        match: [ 'he', 'll' ]
      test.equal options, "hello", "hello"
    it "should fail for match option", ->
      options =
        type: 'string'
        match: 'll'
      test.fail options, "ciao"
    it "should support matchNot option", ->
      options =
        type: 'string'
        matchNot: 'll'
      test.equal options, "ciao", "ciao"
    it "should support multi matchNot option", ->
      options =
        type: 'string'
        matchNot: ['ll', 'pp']
      test.equal options, "ciao", "ciao"
    it "should fail for matchNot option", ->
      options =
        type: 'string'
        matchNot: 'll'
      test.fail options, "hello"

  describe "async check", ->

    it "should match string objects", (cb) ->
      async.series [
        (cb) -> test.equal options, 'hello', 'hello', cb
        (cb) -> test.equal options, '1', '1', cb
        (cb) -> test.equal options, '', '', cb
      ], cb
    it "should fail on other objects", (cb) ->
      async.series [
        (cb) -> test.fail options, 1, cb
        (cb) -> test.fail options, null, cb
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, (new Error '????'), cb
        (cb) -> test.fail options, {}, cb
      ], cb
    it "should support optional option", (cb) ->
      options =
        type: 'string'
        optional: true
      async.series [
        (cb) -> test.equal options, null, null, cb
        (cb) -> test.equal options, undefined, null, cb
      ], cb
    it "should support default option", (cb) ->
      options =
        type: 'string'
        optional: true
        default: ''
      async.series [
        (cb) -> test.equal options, null, '', cb
        (cb) -> test.equal options, undefined, '', cb
      ], cb
    it "should support tostring option", (cb) ->
      options =
        type: 'string'
        tostring: true
      async.series [
        (cb) -> test.equal options, (new Error 'test'), 'Error: test', cb
      ], cb
    it "should support trim option", (cb) ->
      options =
        type: 'string'
        trim: true
      async.series [
        (cb) -> test.equal options, '  hello', 'hello', cb
        (cb) -> test.equal options, 'hello  ', 'hello', cb
        (cb) -> test.equal options, '  hello  ', 'hello', cb
        (cb) -> test.equal options, '', '', cb
      ], cb
    it "should support crop option", (cb) ->
      options =
        type: 'string'
        crop: 8
      async.series [
        (cb) -> test.equal options, '123456789', '12345678', cb
        (cb) -> test.equal options, '123', '123', cb
      ], cb
    it "should support replace option", (cb) ->
      options =
        type: 'string'
        replace: [/a/g, 'o']
      async.series [
        (cb) -> test.equal options, 'great', 'greot', cb
        (cb) -> test.equal options, 'aligator', 'oligotor', cb
      ], cb
    it "should support multi replace option", (cb) ->
      options =
        type: 'string'
        replace: [
          [/a/g, 'o']
          ['m', 'n']
        ]
      async.series [
        (cb) -> test.equal options, 'great', 'greot', cb
        (cb) -> test.equal options, 'aligator', 'oligotor', cb
        (cb) -> test.equal options, 'meet', 'neet', cb
        (cb) -> test.equal options, 'meet me', 'neet me', cb
        (cb) -> test.equal options, 'great meal', 'greot neol', cb
      ], cb
    it "should strip control characters", (cb) ->
      async.series [
        (cb) -> test.equal options, "123\x00456789", "123456789", cb
      ], cb
    it "should support allowControls option", (cb) ->
      options =
        type: 'string'
        allowControls: true
      async.series [
        (cb) -> test.equal options, "123\x00456789", "123\x00456789", cb
      ], cb
    it "should support stripTags option", (cb) ->
      options =
        type: 'string'
        stripTags: true
      async.series [
        (cb) -> test.equal options, "the <b>best</b>", "the best", cb
      ], cb
    it "should support lowercase option", (cb) ->
      options =
        type: 'string'
        lowerCase: true
      async.series [
        (cb) -> test.equal options, "HELLo", "hello", cb
      ], cb
    it "should support lowercase of first character", (cb) ->
      options =
        type: 'string'
        lowerCase: 'first'
      async.series [
        (cb) -> test.equal options, "HELLo", "hELLo", cb
      ], cb
    it "should support uppercase option", (cb) ->
      options =
        type: 'string'
        upperCase: true
      async.series [
        (cb) -> test.equal options, "hello", "HELLO", cb
      ], cb
    it "should support uppercase of first character", (cb) ->
      options =
        type: 'string'
        upperCase: 'first'
      async.series [
        (cb) -> test.equal options, "hello", "Hello", cb
      ], cb
    it "should support minlength option", (cb) ->
      options =
        type: 'string'
        minLength: 5
      async.series [
        (cb) -> test.equal options, "hello", "hello", cb
        (cb) -> test.equal options, "hello to everybody", "hello to everybody", cb
      ], cb
    it "should fail for minlength on too long strings", (cb) ->
      options =
        type: 'string'
        minLength: 5
      async.series [
        (cb) -> test.fail options, "", cb
        (cb) -> test.fail options, "123", cb
      ], cb
    it "should support maxlength option", (cb) ->
      options =
        type: 'string'
        maxLength: 5
      async.series [
        (cb) -> test.equal options, "", "", cb
        (cb) -> test.equal options, "123", "123", cb
        (cb) -> test.equal options, "hello", "hello", cb
      ], cb
    it "should fail for maxlength on too long strings", (cb) ->
      options =
        type: 'string'
        maxLength: 4
      async.series [
        (cb) -> test.fail options, "hello", cb
        (cb) -> test.fail options, "hello to everybody", cb
      ], cb
    it "should support values option", (cb) ->
      options =
        type: 'string'
        values: ['one', 'two', 'three']
      async.series [
        (cb) -> test.equal options, "one", "one", cb
      ], cb
    it "should fail for values option", (cb) ->
      options =
        type: 'string'
        values: ['one', 'two', 'three']
      async.series [
        (cb) -> test.fail options, "", cb
        (cb) -> test.fail options, "nine", cb
        (cb) -> test.fail options, "bananas", cb
      ], cb
    it "should support startsWith option", (cb) ->
      options =
        type: 'string'
        startsWith: 'he'
      async.series [
        (cb) -> test.equal options, "hello", "hello", cb
        (cb) -> test.equal options, "hero", "hero", cb
      ], cb
    it "should fail for startsWith option", (cb) ->
      options =
        type: 'string'
        startsWith: 'he'
      async.series [
        (cb) -> test.fail options, "ciao", cb
        (cb) -> test.fail options, "", cb
      ], cb
    it "should support endsWith option", (cb) ->
      options =
        type: 'string'
        endsWith: 'lo'
      async.series [
        (cb) -> test.equal options, "hello", "hello", cb
      ], cb
    it "should fail for endsWith option", (cb) ->
      options =
        type: 'string'
        endsWith: 'he'
      async.series [
        (cb) -> test.fail options, "ciao", cb
        (cb) -> test.fail options, "", cb
      ], cb
    it "should support match option", (cb) ->
      options =
        type: 'string'
        match: 'll'
      async.series [
        (cb) -> test.equal options, "hello", "hello", cb
      ], cb
    it "should support multi match option", (cb) ->
      options =
        type: 'string'
        match: [ 'he', 'll' ]
      async.series [
        (cb) -> test.equal options, "hello", "hello", cb
      ], cb
    it "should fail for match option", (cb) ->
      options =
        type: 'string'
        match: 'll'
      async.series [
        (cb) -> test.fail options, "ciao", cb
      ], cb
    it "should support matchNot option", (cb) ->
      options =
        type: 'string'
        matchNot: 'll'
      async.series [
        (cb) -> test.equal options, "ciao", "ciao", cb
      ], cb
    it "should support multi matchNot option", (cb) ->
      options =
        type: 'string'
        matchNot: ['ll', 'pp']
      async.series [
        (cb) -> test.equal options, "ciao", "ciao", cb
      ], cb
    it "should fail for matchNot option", (cb) ->
      options =
        type: 'string'
        matchNot: 'll'
      async.series [
        (cb) -> test.fail options, "hello", cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options

