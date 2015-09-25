async = require 'alinex-async'

test = require '../../test'

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

    it.only "should parse date", (cb) ->
      test.equalTime schema, [
        ['2013-02-08', new Date '2013-02-08 12:00']
        ['2013-W06-5', new Date '2013-02-08 12:00']
        ['2013-039', new Date '2013-02-08 12:00']
      ], cb

    it "should parse date with time", (cb) ->
      test.equal schema, [
        ['2013-02-08T09', new Date '2013-02-08 09:00']
        ['2013-02-08 09', new Date '2013-02-08 09:00']
        ['2013-02-08 09:30', new Date '2013-02-08 09:30']
        ['2013-02-08 09:30:26', new Date '2013-02-08 09:30:26']
        ['2013-02-08 09:30:26.123', new Date '2013-02-08 09:30:26.123']
        ['2013-02-08 24:00:00.00', new Date '2013-02-00 00:00:0']
      ], cb

    it "should parse time", (cb) ->
      test.equal schema, [
        ['09', new Date '2013-02-08 09:00']
        ['9:30', new Date '2013-02-08 09:30']
        ['09:30', new Date '2013-02-08 09:30']
        ['09:30:26', new Date '2013-02-08 09:30:26']
        ['09:30:26.123', new Date '2013-02-08 09:30:26.123']
        ['24:00:00.00', new Date '2013-02-00 00:00:0']
      ], cb

    it "should parse date parts with time", (cb) ->
      test.equal schema, [
        ['2013-02-08 09', new Date '2013-02-08 09:00']
        ['2013-W06-5 09', new Date '2013-02-08 09:00']
        ['2013-039 09', new Date '2013-02-08 09:00']
      ], cb

    it "should parse date with time and timezone", (cb) ->
      test.equal schema, [
        ['2013-02-08 09+07:00', new Date '2013-02-08 09:00']
        ['2013-02-08 09-0100', new Date '2013-02-08 09:00']
        ['2013-02-08 09Z', new Date '2013-02-08 09:00']
        ['2013-02-08 09:30:26.123+07:00', new Date '2013-02-08 09:00']
      ], cb

  describe "natural language", ->

    it "should parse reference names", (cb) ->
      test.equal schema, [
        ['2013-02-08 09+07:00', new Date '2013-02-08 09:00']
        ['2013-02-08 09-0100', new Date '2013-02-08 09:00']
        ['2013-02-08 09Z', new Date '2013-02-08 09:00']
        ['2013-02-08 09:30:26.123+07:00', new Date '2013-02-08 09:00']
      ], cb

# Today, Tomorrow, Yesterday, Last Friday, etc
# 17 August 2013 - 19 August 2013
# This Friday from 13:00 - 16.00
# 5 days ago
# Sat Aug 17 2013 18:40:39 GMT+0900 (JST)
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
