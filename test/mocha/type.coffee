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
      testFail null, options
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
    it "should match string objects", ->
      testFail 1, options
      testFail null, options
      testFail [], options
      testFail (new Error '????'), options
      testFail {}, options
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
          replace: [
            [/a/g, 'o']
            ['m', 'n']
          ]
      testEqual 'great', options, 'greot'
      testEqual 'aligator', options, 'oligotor'
      testEqual 'meet', options, 'neet'
      testEqual 'meet me', options, 'neet me'
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
