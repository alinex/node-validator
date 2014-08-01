chai = require 'chai'
expect = chai.expect

describe "Type checks", ->

  validator = require '../../lib/index'

  describe "for boolean", ->

    options =
      check: 'type.boolean'

    testTrue = (value) ->
      expect validator.check('test', value, options)
      , value
      .to.be.true
    testFalse = (value) ->
      expect validator.check('test', value, options)
      , value
      .to.be.false
    testFail = (value) ->
      expect validator.check('test', value, options)
      , value
      .to.be.an.instanceof Error

    it "should match real booleans", ->
      testTrue true
      testFalse false
    it "should match numbers", ->
      testTrue 1
      testFalse 0
      testTrue 1.0
      testFalse 0x0000
    it "should match strings", ->
      testTrue 'true'
      testFalse 'false'
      testTrue 'on'
      testFalse 'off'
      testTrue 'yes'
      testFalse 'no'
      testTrue 'TRUE'
      testFalse 'FALSE'
      testTrue 'On'
      testFalse 'Off'
      testTrue 'Yes'
      testFalse 'No'
    it "should fail on other strings", ->
      testFail 'Hello'
      testFail 'Nobody'
      testFail 'o'
    it "should fail on other numbers", ->
      testFail 3
      testFail -1
      testFail 0.1
    it "should fail on other types", ->
      testFail null
      testFail []
      testFail new Error '????'
      testFail {}
    it "should give description", ->
      desc = validator.describe options
      expect(desc).to.be.a 'string'
      expect(desc).to.have.length.of.at.least 30

