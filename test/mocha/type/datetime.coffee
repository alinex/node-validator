async = require 'alinex-async'
moment = require 'moment'
chai = require 'chai'
expect = chai.expect

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
      schema.default = '1974-01-23'
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

  describe.only "natural language", ->

    it "should parse reference names", (cb) ->
      test.equal schema, [
        ['today', moment(new Date).hour(12).minute(0).second(0).millisecond(0).toDate()]
        ['tomorrow', moment(new Date).add(1, 'day').hour(12).minute(0).second(0).millisecond(0).toDate()]
        ['yesterday', moment(new Date).subtract(1, 'day').hour(12).minute(0).second(0).millisecond(0).toDate()]
        ['last friday', moment(new Date).subtract(7, 'days').day(5).hour(12).minute(0).second(0).millisecond(0).toDate()]
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
        ['This Friday at 13:00', moment(new Date).day(5).hour(13).minute(0).second(0).millisecond(0).toDate()]
        ['5 days ago', moment(new Date).subtract(5, 'days').hour(12).minute(0).second(0).millisecond(0).toDate()]
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

# This Friday from 13:00 - 16.00
# 2014-11-30T08:15:30-05:30


  describe.skip "option check", ->

    it "should support min option", (cb) ->
      schema.min = -2
      test.same schema, [6, 0, -2], ->
        test.fail schema, [-8], cb

    it "should support max option", (cb) ->
      schema.max = 12
      test.same schema, [6, 0, -2, 12], ->
        schema.max = -2
        test.fail schema, [100, -1], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'datetime'
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'datetime'
      , cb
