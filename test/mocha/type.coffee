chai = require 'chai'
expect = chai.expect
require('alinex-error').install()

describe "Type checks", ->

  validator = require '../../lib/index'

  testTrue = (value, options) ->
    expect validator.check('test', value, options)
    , value
    .to.be.true
  testFalse = (value, options) ->
    expect validator.check('test', value, options)
    , value
    .to.be.false
  testFail = (value, options) ->
    expect validator.check('test', value, options)
    , value
    .to.be.an.instanceof Error
  testEqual = (value, options, result) ->
    expect validator.check('test', value, options)
    , value
    .to.equal result
  testDesc = (options) ->
    desc = validator.describe options
    expect(desc).to.be.a 'string'
    expect(desc).to.have.length.of.at.least 10

  describe "for boolean", ->

    options =
      check: 'type.boolean'

    it "should match real booleans", ->
      testTrue true, options
      testFalse false, options
    it "should be false on undefined", ->
      testFalse null, options
      testFalse undefined, options
    it "should match numbers", ->
      testTrue 1, options
      testFalse 0, options
      testTrue 1.0, options
      testFalse 0x0000, options
    it "should match strings", ->
      testTrue 'true', options
      testFalse 'false', options
      testTrue 'on', options
      testFalse 'off', options
      testTrue 'yes', options
      testFalse 'no', options
      testTrue 'TRUE', options
      testFalse 'FALSE', options
      testTrue 'On', options
      testFalse 'Off', options
      testTrue 'Yes', options
      testFalse 'No', options
    it "should fail on other strings", ->
      testFail 'Hello', options
      testFail 'Nobody', options
      testFail 'o', options
    it "should fail on other numbers", ->
      testFail 3, options
      testFail -1, options
      testFail 0.1, options
    it "should fail on other types", ->
      testFail [], options
      testFail (new Error '????'), options
      testFail {}, options
    it "should give description", ->
      testDesc options

  describe "for string", ->

    options =
      check: 'type.string'

    it "should match string objects", ->
      testEqual 'hello', options, 'hello'
      testEqual '1', options, '1'
      testEqual '', options, ''
    it "should fail on other objects", ->
      testFail 1, options
      testFail null, options
      testFail [], options
      testFail (new Error '????'), options
      testFail {}, options
    it "should support optional option", ->
      options =
        check: 'type.string'
        options:
          optional: true
      testEqual null, options, null
      testEqual undefined, options, null
    it "should support tostring option", ->
      options =
        check: 'type.string'
        options:
          tostring: true
      testEqual [], options, ''
      testEqual {}, options, '[object Object]'
      testEqual (new Error 'test'), options, 'Error: test'
    it "should support trim option", ->
      options =
        check: 'type.string'
        options:
          trim: true
      testEqual '  hello', options, 'hello'
      testEqual 'hello  ', options, 'hello'
      testEqual '  hello  ', options, 'hello'
      testEqual '', options, ''
    it "should support crop option", ->
      options =
        check: 'type.string'
        options:
          crop: 8
      testEqual '123456789', options, '12345678'
      testEqual '123', options, '123'
    it "should support replace option", ->
      options =
        check: 'type.string'
        options:
          replace: [/a/g, 'o']
      testEqual 'great', options, 'greot'
      testEqual 'aligator', options, 'oligotor'
    it "should support multi replace option", ->
      options =
        check: 'type.string'
        options:
          replace: [
            [/a/g, 'o']
            ['m', 'n']
          ]
      testEqual 'great', options, 'greot'
      testEqual 'aligator', options, 'oligotor'
      testEqual 'meet', options, 'neet'
      testEqual 'meet me', options, 'neet me'
      testEqual 'great meal', options, 'greot neol'
    it "should strip control characters", ->
      testEqual "123\x00456789", options, "123456789"
    it "should support allowControls option", ->
      options =
        check: 'type.string'
        options:
          allowControls: true
      testEqual "123\x00456789", options, "123\x00456789"
    it "should support stripTags option", ->
      options =
        check: 'type.string'
        options:
          stripTags: true
      testEqual "the <b>best</b>", options, "the best"
    it "should support lowercase option", ->
      options =
        check: 'type.string'
        options:
          lowerCase: true
      testEqual "HELLo", options, "hello"
    it "should support lowercase of first character", ->
      options =
        check: 'type.string'
        options:
          lowerCase: 'first'
      testEqual "HELLo", options, "hELLo"
    it "should support uppercase option", ->
      options =
        check: 'type.string'
        options:
          upperCase: true
      testEqual "hello", options, "HELLO"
    it "should support uppercase of first character", ->
      options =
        check: 'type.string'
        options:
          upperCase: 'first'
      testEqual "hello", options, "Hello"
    it "should support minlength option", ->
      options =
        check: 'type.string'
        options:
          minLength: 5
      testEqual "hello", options, "hello"
      testEqual "hello to everybody", options, "hello to everybody"
    it "should fail for minlength on too long strings", ->
      options =
        check: 'type.string'
        options:
          minLength: 5
      testFail "", options
      testFail "123", options
    it "should support maxlength option", ->
      options =
        check: 'type.string'
        options:
          maxLength: 5
      testEqual "", options, ""
      testEqual "123", options, "123"
      testEqual "hello", options, "hello"
    it "should fail for maxlength on too long strings", ->
      options =
        check: 'type.string'
        options:
          maxLength: 4
      testFail "hello", options
      testFail "hello to everybody", options
    it "should support values option", ->
      options =
        check: 'type.string'
        options:
          values: ['one', 'two', 'three']
      testEqual "one", options, "one"
    it "should fail for values option", ->
      options =
        check: 'type.string'
        options:
          values: ['one', 'two', 'three']
      testFail "", options
      testFail "nine", options
      testFail "bananas", options
    it "should support startsWith option", ->
      options =
        check: 'type.string'
        options:
          startsWith: 'he'
      testEqual "hello", options, "hello"
      testEqual "hero", options, "hero"
    it "should fail for startsWith option", ->
      options =
        check: 'type.string'
        options:
          startsWith: 'he'
      testFail "ciao", options
      testFail "", options
    it "should support endsWith option", ->
      options =
        check: 'type.string'
        options:
          endsWith: 'lo'
      testEqual "hello", options, "hello"
    it "should fail for endsWith option", ->
      options =
        check: 'type.string'
        options:
          endsWith: 'he'
      testFail "ciao", options
      testFail "", options
    it "should support match option", ->
      options =
        check: 'type.string'
        options:
          match: 'll'
      testEqual "hello", options, "hello"
    it "should support multi match option", ->
      options =
        check: 'type.string'
        options:
          match: [ 'he', 'll' ]
      testEqual "hello", options, "hello"
    it "should fail for match option", ->
      options =
        check: 'type.string'
        options:
          match: 'll'
      testFail "ciao", options
    it "should support matchNot option", ->
      options =
        check: 'type.string'
        options:
          matchNot: 'll'
      testEqual "ciao", options, "ciao"
    it "should support multi matchNot option", ->
      options =
        check: 'type.string'
        options:
          matchNot: ['ll', 'pp']
      testEqual "ciao", options, "ciao"
    it "should fail for matchNot option", ->
      options =
        check: 'type.string'
        options:
          matchNot: 'll'
      testFail "hello", options

