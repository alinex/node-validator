require('alinex-error').install()
chai = require 'chai'
expect = chai.expect

async = require 'alinex-async'

test = require '../test'
reference = require '../../lib/reference'

describe.only "References", ->

  describe "detect", ->

    it "should know that there are no references", ->
      values = [
        'one'
        1
        [1,2,3]
        { one: 1 }
        new Error '????'
        undefined
        null
      ]
      for value in values
        result = reference.exists value
        expect(result, value).to.be.false

    it "should find references", ->
      values = [
        '<<<name>>>'
        'My name is <<<name>>>'
        '<<<firstname>>> <<<lastname>>>'
      ]
      for value in values
        result = reference.exists value
        expect(result, value).to.be.true

  describe "simple", ->

    it "should keep values without references", ->
      values = [
        'one'
        1
        [1,2,3]
        { one: 1 }
        new Error '????'
        undefined
        null
      ]
      for value in values
        result = reference.replace value
        expect(result, value).to.equal value

    it "should replace references with default value", ->
      values =
        '<<<>>>': '' # empty default value
        '<<<name>>>': 'name' # whole reference
        'My name is <<<alex>>>': 'My name is alex' # reference in string
        '<<<firstname>>> <<<lastname>>>': 'firstname lastname' #concatenate
      for value, check of values
        result = reference.replace value
        expect(result, value).to.equal check

  describe "data sources", ->

    it "should find environment value", ->
      process.env.TESTVALIDATOR = 123
      value = '<<<env://TESTVALIDATOR>>>'
      result = reference.replace value
      expect(result, value).to.equal process.env.TESTVALIDATOR
    it "should fail for environment", ->
      value = '<<<env://TESTNOTEXISTING>>>'
      result = reference.replace value
      expect(result, value).to.not.exist

    it.skip "should find file value", ->

    it.skip "should find command value", ->

    it.skip "should find web resource value", ->

  describe "structure", ->

    it "should find absolute path", ->
      struct =
        absolute: 123
      value = '<<<struct:///absolute>>>'
      result = reference.replace value,
        data: struct
      expect(result, value).to.equal struct.absolute

  describe "context", ->

  describe "alternatives", ->

  describe "value search", ->

    it.skip "should find line", ->

  describe "checks", ->

  describe "multipath", ->

  describe "multiref", ->
