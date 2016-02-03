async = require 'alinex-async'
moment = require 'moment'
chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

test = require '../../test'
validator = require '../../../src/index'

describe "Datetime", ->

  schema = null
  beforeEach ->
    schema =
      type: 'datetime'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = new Date '1974-01-23'
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "ISO 8601", ->

    it "should parse date", (cb) ->
      test.equalTime schema, [
        ['2013-02-08', new Date '2013-02-08 00:00']
        ['2013-W06-5', new Date '2013-02-08 00:00']
        ['2013-039', new Date '2013-02-08 00:00']
      ], cb

    it "should parse date with time", (cb) ->
      test.equal schema, [
        ['2013-02-08 09', new Date '2013-02-08 09:00']
        ['2013-02-08T09', new Date '2013-02-08 09:00']
        ['2013-02-08 09:30', new Date '2013-02-08 09:30']
        ['2013-02-08T09:30', new Date '2013-02-08 09:30']
        ['2013-02-08 09:30:26', new Date '2013-02-08 09:30:26']
        ['2013-02-08T09:30:26', new Date '2013-02-08 09:30:26']
        ['2013-02-08 09:30:26.123', new Date '2013-02-08 09:30:26.123']
        ['2013-02-08 24:00:00.00', new Date '2013-02-09 00:00:0']
      ], cb

    it "should parse time", (cb) ->
      test.equal schema, [
        ['9:30', moment(new Date()).hour(9).minute(30).second(0).millisecond(0).toDate()]
        ['09:30', moment(new Date()).hour(9).minute(30).second(0).millisecond(0).toDate()]
        ['09:30:26', moment(new Date()).hour(9).minute(30).second(26).millisecond(0).toDate()]
        ['24:00:00', moment(new Date()).hour(24).minute(0).second(0).millisecond(0).toDate()]
      ], cb

    it "should parse date parts with time", (cb) ->
      test.equal schema, [
        ['2013-02-08 09', new Date '2013-02-08 09:00']
        ['2013-W06-5 09', new Date '2013-02-08 09:00']
        ['2013-039 09', new Date '2013-02-08 09:00']
      ], cb

    it "should parse date with time and timezone", (cb) ->
      test.equal schema, [
        ['2013-02-08 09+07:00', new Date '2013-02-08 03:00']
        ['2013-02-08 09-0100', new Date '2013-02-08 11:00']
        ['2013-02-08 09Z', new Date '2013-02-08 10:00']
        ['2013-02-08 09:30:26.123+07:00', new Date '2013-02-08 03:30:26.123']
      ], cb

  describe "natural language", ->

    it "should parse reference names", (cb) ->
      test.equal schema, [
        ['today', moment(new Date()).hour(12).minute(0).second(0).millisecond(0).toDate()]
        ['tomorrow', moment(new Date()).add(1, 'day').hour(12).minute(0).second(0)
        .millisecond(0).toDate()]
        ['yesterday', moment(new Date()).subtract(1, 'day').hour(12).minute(0).second(0)
        .millisecond(0).toDate()]
        ['last friday', moment(new Date()).subtract(7, 'days').day(5).hour(12).minute(0)
        .second(0).millisecond(0).toDate()]
      ], cb

    it "should parse named dates", (cb) ->
      test.equal schema, [
        ['17 August 2013', new Date '2013-08-17 12:00']
        ['19 Aug 2013', new Date '2013-08-19 12:00']
        ['20 Aug. 2013', new Date '2013-08-20 12:00']
      ], cb

    it "should parse named dates with time", (cb) ->
      test.equal schema, [
        ['Sat Aug 17 2013 18:40:39 GMT+0900 (JST)', new Date '2013-08-17 11:40:39']
      ], cb

    it "should parse relative date", (cb) ->
      test.equal schema, [
        ['This Friday at 13:00', moment(new Date()).day(5).hour(13).minute(0)
        .second(0).millisecond(0).toDate()]
        ['5 days ago', moment(new Date()).subtract(5, 'days').hour(12).minute(0)
        .second(0).millisecond(0).toDate()]
      ], cb

    it "should parse now", (cb) ->
      validator.check
        name: "now"
        schema: schema
        value: 'now'
      , (err, result) ->
        expect(err, 'error').to.not.exist
        now = new Date().getTime()
        expect(result.getTime(), 'result').to.be.within now-1000, now
        cb()

    it "should parse ranges", (cb) ->
      schema.range = true
      test.equal schema, [
        ['This Friday from 13:00 - 16.00', [
          moment(new Date()).day(5).hour(13).minute(0).second(0).millisecond(0).toDate()
          moment(new Date()).day(5).hour(16).minute(0).second(0).millisecond(0).toDate()
        ]]
      ], cb

  describe "range check", ->

    it "should support min option", (cb) ->
      schema.min = 'now'
      test.success schema, ['now', 'tomorrow'], ->
        test.fail schema, ['yesterday'], cb

    it "should support max option", (cb) ->
      schema.max = 'now'
      test.success schema, ['yesterday'], ->
        test.fail schema, ['tomorrow'], cb

  describe "format check", ->

    it "should get the unix timestamp", (cb) ->
      schema.format = 'unix'
      test.equal schema, [
        ['2015-01-17 09:00', new Date('2015-01-17 09:00').getTime()/1000]
      ], cb

    it "should format using moment.js custom strings", (cb) ->
      date = new Date('2015-01-17 09:00')
      testFormat schema, date, [
        ['YYYY-MM-DD', moment(date).format 'YYYY-MM-DD']
      ], cb

    it "should format using moment.js local strings", (cb) ->
      schema.locale = 'de'
      date = new Date('2015-01-17 09:00')
      testFormat schema, date, [
        ['L', moment(date).locale('de').format 'L']
      ], cb

    it "should format using defined datetime formats", (cb) ->
      date = new Date('2015-01-17 09:00')
      testFormat schema, date, [
        ['ISO8601', moment(date).format 'YYYY-MM-DDTHH:mm:ssZ']
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'datetime'
        default: 'now'
        min: 'now'
        max: '2020-01-01'
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'datetime'
        default: 'now'
        min: 'now'
        max: '2020-01-01'
      , cb



testFormat = (schema, value, formats, cb) ->
  num = 0
  async.each formats, ([format, goal], cb) ->
    schema.format = format
    validator.check
      name: "format-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.deep.equal goal
      cb()
  , cb
