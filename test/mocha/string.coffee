require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "String", ->

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

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'string'
        optional: true
        default: 'nix'
        tostring: true
        allowControls: true
        stripTags: true
        lowerCase: true
        upperCase: 'first'
        replace: ['test', 'done']
        trim: true
        crop: 50
        minLength: 5
        maxLength: 50
        values: ['Kopenhagen', 'Amsterdam', 'Hannover']
        startsWith: 'H'
        endsWith: 'r'
        match: /\w+/
        matchNot: /\d/

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'string'
        optional: true
        default: 'nix'
        tostring: true
        allowControls: true
        stripTags: true
        lowerCase: true
        upperCase: 'first'
        replace: ['test', 'done']
        trim: true
        crop: 50
        minLength: 5
        maxLength: 50
        values: ['Kopenhagen', 'Amsterdam', 'Hannover']
        startsWith: 'H'
        endsWith: 'r'
        match: /\w+/
        matchNot: /\d/
