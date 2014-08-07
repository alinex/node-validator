chai = require 'chai'
expect = chai.expect
require('alinex-error').install()

describe "Date checks", ->

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
  testDeep = (value, options, result) ->
    expect validator.check('test', value, options)
    , value
    .to.deep.equal result
  testInstance = (value, options, result) ->
    expect validator.check('test', value, options)
    , value
    .to.be.an.instanceof result
  testDesc = (options) ->
    desc = validator.describe options
    expect(desc).to.be.a 'string'
    expect(desc).to.have.length.of.at.least 10

  describe.only "for interval", ->

    options =
      check: 'date.interval'

    it "should match number objects", ->
      testEqual 18, options, 18
      testEqual 0, options, 0
      testEqual 118371, options, 118371
    it "should match string definition", ->
      testEqual '12ms', options, 12
      testEqual '1s', options, 1000
      testEqual '1m', options, 60000
    it "should fail on other objects", ->
      testFail 'hello', options
      testFail null, options
      testFail [], options
      testFail (new Error '????'), options
      testFail {}, options
    it "should support optional option", ->
      options =
        check: 'date.interval'
        optional: true
      testEqual null, options, null
      testEqual undefined, options, null
    it "should support round option", ->
      options =
        check: 'date.interval'
        round: true
      testEqual 13.5, options, 14
      testEqual -9.49, options, -9
      testEqual '+18.6', options, 19
    it "should support round (floor) option", ->
      options =
        check: 'date.interval'
        round: 'floor'
      testEqual 13.5, options, 13
      testEqual -9.49, options, -10
      testEqual '+18.6', options, 18
    it "should support round (ceil) option", ->
      options =
        check: 'date.interval'
        round: 'ceil'
      testEqual 13.5, options, 14
      testEqual -9.49, options, -9
      testEqual '+18.2', options, 19
    it "should support min option", ->
      options =
        check: 'date.interval'
        min: -2
      testEqual 6, options, 6
      testEqual 0, options, 0
      testEqual -2, options, -2
    it "should fail for min option", ->
      options =
        check: 'date.interval'
        min: -2
      testFail -8, options
    it "should support max option", ->
      options =
        check: 'date.interval'
        max: 12
      testEqual 6, options, 6
      testEqual 0, options, 0
      testEqual -2, options, -2
      testEqual 12, options, 12
    it "should fail for max option", ->
      options =
        check: 'date.interval'
        max: -2
      testFail 100, options
      testFail -1, options
    it "should give description", ->
      testDesc options
