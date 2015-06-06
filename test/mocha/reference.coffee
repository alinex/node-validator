require('alinex-error').install()
chai = require 'chai'
expect = chai.expect

async = require 'alinex-async'
path = require 'path'

test = require '../test'
reference = require '../../lib/reference'

describe "References", ->

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

    it "should keep values without references", (cb) ->
      values = [
        'one'
        1
        [1,2,3]
        { one: 1 }
        new Error '????'
        undefined
        null
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal value
          cb()
      , cb

    it "should replace references with default value", (cb) ->
      values =
        '<<<>>>': '' # empty default value
        '<<<name>>>': 'name' # whole reference
        'My name is <<<alex>>>': 'My name is alex' # reference in string
        '<<<firstname>>> <<<lastname>>>': 'firstname lastname' #concatenate
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

    it "should use alternatives", (cb) ->
      process.env.TESTVALIDATOR = 123
      values =
        '<<<env://TESTVALIDATOR | 456>>>': process.env.TESTVALIDATOR
        '<<<env://NOTEXISTING | 456>>>': '456'
        '<<<env://NOTEXISTING | env://TESTVALIDATOR | 456>>>': process.env.TESTVALIDATOR
        '<<<env://TESTVALIDATOR | env://NOTEXISTING | 456>>>': process.env.TESTVALIDATOR
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

  describe "environment", ->

    it "should find environment value", (cb) ->
      process.env.TESTVALIDATOR = 123
      value = '<<<env://TESTVALIDATOR>>>'
      reference.replace value, (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, value).to.equal process.env.TESTVALIDATOR
        cb()

    it "should fail for environment", (cb) ->
      value = '<<<env://TESTNOTEXISTING>>>'
      reference.replace value, (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, value).to.not.exist
        cb()

  describe "structure", ->

    it "should find absolute path", (cb) ->
      struct =
        absolute: 123
      value = '<<<struct:///absolute>>>'
      reference.replace value,
        data: struct
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, value).to.equal struct.absolute
        cb()

    it "should fail with absolute path", (cb) ->
      struct =
        absolute: 123
      values = [
        '<<<struct:///notfound>>>'
        '<<<struct:///notfound/value>>>'
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value,
          data: struct
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

    it "should find relative path", (cb) ->
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
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: struct
          pos: ['europe','germany']
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.deep.equal check
          cb()
      , cb

    it "should fail with relative path", (cb) ->
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
      async.eachSeries values, (value, cb) ->
        reference.replace value,
          data: struct
          pos: ['europe','germany']
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

    it "should find context path", (cb) ->
      struct =
        absolute: 123
      values = [
        '<<<context:///absolute>>>'
        '<<<context://absolute>>>'
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value,
          context: struct
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal struct.absolute
          cb()
      , cb

  describe "file", ->

    it "should find file value", (cb) ->
      values = [
        "<<<file://#{path.dirname __dirname}/data/textfile>>>"
        "<<<file://test/data/textfile>>>"
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal '123'
          cb()
      , cb

    it "should fail on file", (cb) ->
      values = [
        "<<<file://#{path.dirname __dirname}/data/notfound>>>"
        "<<<file://textfile>>>"
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

  describe "web", ->
    @timeout 10000

    it "should find http/https value", (cb) ->
      values =
        '<<<https://raw.githubusercontent.com/alinex/node-validator/master/test/data/textfile>>>': '123'
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

    it "should fail on web resource", (cb) ->
      values = [
        "<<<http://www.this-server-did-not-exist-here.org>>>"
        "<<<http://www.heise.de/page-did-not-exist-here>>>"
      ]
      async.each values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

  describe "command", ->

    it "should execute commands", (cb) ->
      values =
        '<<<cmd://uname>>>': 'Linux\n'
        '<<<cmd://cat test/data/textfile>>>': '123'
        '<<<cmd://cat test/data/poem| head -1>>>': 'William B Yeats (1865-1939)\n'
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

  describe "value search", ->

  describe.skip "checks", ->

    it "should check against integer", (cb) ->
      struct =
        number: 123
        string: '123'
      values =
        '<<<struct:///number#{type:"integer"}>>>': 123
        '<<<struct:///number#{type:"integer"}>>>': 123
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: struct
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

  describe "multipath", ->

  describe "multiref", ->
