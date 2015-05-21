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

    it "should use alternatives value", ->
      process.env.TESTVALIDATOR = 123
      values =
        '<<<env://TESTVALIDATOR | 456>>>': process.env.TESTVALIDATOR
        '<<<env://NOTEXISTING | 456>>>': '456'
        '<<<env://NOTEXISTING | env://TESTVALIDATOR | 456>>>': process.env.TESTVALIDATOR
        '<<<env://TESTVALIDATOR | env://NOTEXISTING | 456>>>': process.env.TESTVALIDATOR
      for value, check of values
        result = reference.replace value
        expect(result, value).to.equal check

  describe "environment", ->

    it "should find environment value", ->
      process.env.TESTVALIDATOR = 123
      value = '<<<env://TESTVALIDATOR>>>'
      result = reference.replace value
      expect(result, value).to.equal process.env.TESTVALIDATOR

    it "should fail for environment", ->
      value = '<<<env://TESTNOTEXISTING>>>'
      result = reference.replace value
      expect(result, value).to.not.exist

  describe "structure", ->

    it "should find absolute path", ->
      struct =
        absolute: 123
      value = '<<<struct:///absolute>>>'
      result = reference.replace value,
        data: struct
      expect(result, value).to.equal struct.absolute

    it "should fail with absolute path", ->
      struct =
        absolute: 123
      values = [
        '<<<struct:///notfound>>>'
        '<<<struct:///notfound/value>>>'
      ]
      for value in values
        result = reference.replace value,
          data: struct
        expect(result, value).to.not.exist

    it "should find relative path", ->
      struct =
        europe:
          germany:
            stuttgart: 'VFB Stuttgart'
            munich: 'FC Bayern'
          spain:
            madrid: 'Real Madrid'
        southamerica:
          brazil:
            saopaulo: 'FC Sao Paulo'
      values =
        '<<<struct://stuttgart>>>': struct.europe.germany.stuttgart
        '<<<struct://munich>>>': struct.europe.germany.munich
        '<<<struct://spain>>>': struct.europe.spain
        '<<<struct://spain/madrid>>>': struct.europe.spain.madrid
        '<<<struct://southamerica/brazil/saopaulo>>>': struct.southamerica.brazil.saopaulo
      for value, check of values
        result = reference.replace value,
          data: struct
          pos: ['europe','germany']
        expect(result, value).to.deep.equal check

    it "should fail with relative path", ->
      struct =
        europe:
          germany:
            stuttgart: 'VFB Stuttgart'
            munich: 'FC Bayern'
          spain:
            madrid: 'Real Madrid'
        southamerica:
          brazil:
            saopaulo: 'FC Sao Paulo'
      values = [
        '<<<struct:///berlin>>>'
        '<<<struct:///america/newyork>>>'
        '<<<struct:///southamerica/chile>>>'
      ]
      for value in values
        result = reference.replace value,
          data: struct
          pos: ['europe','germany']
        expect(result, value).to.not.exist

    it "should find context path", ->
      struct =
        absolute: 123
      values = [
        '<<<context:///absolute>>>'
        '<<<context://absolute>>>'
      ]
      for value in values
        result = reference.replace value,
          context: struct
        expect(result, value).to.equal struct.absolute

  describe.skip "file", ->

    it "should find file value", ->
      value = "<<<file://#{path.dirname __dirname}/textfile>>>"
      result = reference.replace value
      expect(result, value).to.equal '123'

  describe "web", ->

  describe "command", ->

  describe "database", ->

  describe "value search", ->

    it.skip "should find line", ->

  describe "checks", ->

  describe "multipath", ->

  describe "multiref", ->
