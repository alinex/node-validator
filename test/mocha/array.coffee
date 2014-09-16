require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "Array", ->

  options = null

  beforeEach ->
    options =
      type: 'array'

  describe "sync check", ->

    it "should match array objects", ->
      test.deep options, [1,2,3], [1,2,3]
      test.deep options, ['one','two'], ['one','two']
      test.deep options, [], []
      test.deep options, new Array(), []
    it "should fail on other objects", ->
      test.fail options, ''
      test.fail options, null
      test.fail options, 16
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'array'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support notEmpty option", ->
      options =
        type: 'array'
        notEmpty: true
      test.deep options, [1,2,3], [1,2,3]
      test.deep options, ['one','two'], ['one','two']
    it "should fail for notEmpty option", ->
      options =
        type: 'array'
        notEmpty: true
      test.fail options, []
      test.fail options, new Array()
    it "should support delimiter option", ->
      options =
        type: 'array'
        delimiter: ','
      test.deep options, '1,2,3', ['1','2','3']
    it "should support minLength option", ->
      options =
        type: 'array'
        minLength: 2
      test.deep options, [1,2,3], [1,2,3]
      test.deep options, ['one','two'], ['one','two']
    it "should fail for minLength option", ->
      options =
        type: 'array'
        minLength: 2
      test.fail options, []
      test.fail options, new Array()
      test.fail options, [1]
    it "should support maxLength option", ->
      options =
        type: 'array'
        maxLength: 2
      test.deep options, [1], [1]
      test.deep options, ['one','two'], ['one','two']
      test.deep options, [], []
      test.deep options, new Array(), []
    it "should fail for maxLength option", ->
      options =
        type: 'array'
        maxLength: 2
      test.fail options, [1,2,3]
    it "should support exact length option", ->
      options =
        type: 'array'
        minLength: 2
        maxLength: 2
      test.deep options, [1,2], [1,2]
    it "should fail for exact length option", ->
      options =
        type: 'array'
        minLength: 2
        maxLength: 2
      test.fail options, [1,2,3]
      test.fail options, [1]
    it "should support subchecks", ->
      options =
        type: 'array'
        entries:
          type: 'integer'
      test.deep options, [1,2], [1,2]
      test.deep options, [], []
    it "should fail for subchecks", ->
      options =
        type: 'array'
        entries:
          type: 'integer'
      test.fail options, ['one']
      test.fail options, [1,'two']
    it "should support different subchecks", ->
      options =
        type: 'array'
        entries: [
          type: 'integer'
        ,
          type: 'float'
        ]
      test.deep options, [1,2.0], [1,2]
      test.deep options, [], []

  describe "async check", ->

    it "should match array objects", (cb) ->
      async.series [
        (cb) -> test.deep options, [1,2,3], [1,2,3], cb
        (cb) -> test.deep options, ['one','two'], ['one','two'], cb
        (cb) -> test.deep options, [], [], cb
        (cb) -> test.deep options, new Array(), [], cb
      ], cb
    it "should fail on other objects", (cb) ->
      async.series [
        (cb) -> test.fail options, '', cb
        (cb) -> test.fail options, null, cb
        (cb) -> test.fail options, 16, cb
        (cb) -> test.fail options, (new Error '????'), cb
        (cb) -> test.fail options, {}, cb
      ], cb
    it "should support optional option", (cb) ->
      options =
        type: 'array'
        optional: true
      async.series [
        (cb) -> test.equal options, null, null, cb
        (cb) -> test.equal options, undefined, null, cb
      ], cb
    it "should support notEmpty option", (cb) ->
      options =
        type: 'array'
        notEmpty: true
      async.series [
        (cb) -> test.deep options, [1,2,3], [1,2,3], cb
        (cb) -> test.deep options, ['one','two'], ['one','two'], cb
      ], cb
    it "should fail for notEmpty option", (cb) ->
      options =
        type: 'array'
        notEmpty: true
      async.series [
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, new Array(), cb
      ], cb
    it "should support delimiter option", (cb) ->
      options =
        type: 'array'
        delimiter: ','
      async.series [
        (cb) -> test.deep options, '1,2,3', ['1','2','3'], cb
      ], cb
    it "should support minLength option", (cb) ->
      options =
        type: 'array'
        minLength: 2
      async.series [
        (cb) -> test.deep options, [1,2,3], [1,2,3], cb
        (cb) -> test.deep options, ['one','two'], ['one','two'], cb
      ], cb
    it "should fail for minLength option", (cb) ->
      options =
        type: 'array'
        minLength: 2
      async.series [
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, new Array(), cb
        (cb) -> test.fail options, [1], cb
      ], cb
    it "should support maxLength option", (cb) ->
      options =
        type: 'array'
        maxLength: 2
      async.series [
        (cb) -> test.deep options, [1], [1], cb
        (cb) -> test.deep options, ['one','two'], ['one','two'], cb
        (cb) -> test.deep options, [], [], cb
        (cb) -> test.deep options, new Array(), [], cb
      ], cb
    it "should fail for maxLength option", (cb) ->
      options =
        type: 'array'
        maxLength: 2
      async.series [
        (cb) -> test.fail options, [1,2,3], cb
      ], cb
    it "should support exact length option", (cb) ->
      options =
        type: 'array'
        minLength: 2
        maxLength: 2
      async.series [
        (cb) -> test.deep options, [1,2], [1,2], cb
      ], cb
    it "should fail for exact length option", (cb) ->
      options =
        type: 'array'
        minLength: 2
        maxLength: 2
      async.series [
        (cb) -> test.fail options, [1,2,3], cb
        (cb) -> test.fail options, [1], cb
      ], cb
    it "should support subchecks", (cb) ->
      options =
        type: 'array'
        entries:
          type: 'integer'
      async.series [
        (cb) -> test.deep options, [1,2], [1,2], cb
        (cb) -> test.deep options, [], [], cb
      ], cb
    it "should fail for subchecks", (cb) ->
      options =
        type: 'array'
        entries:
          type: 'integer'
      async.series [
        (cb) -> test.fail options, ['one'], cb
        (cb) -> test.fail options, [1,'two'], cb
      ], cb
    it "should support different subchecks", (cb) ->
      options =
        type: 'array'
        entries: [
          type: 'integer'
        ,
          type: 'float'
        ]
      async.series [
        (cb) -> test.deep options, [1,2.0], [1,2], cb
        (cb) -> test.deep options, [], [], cb
      ], cb

  describe "description", (cb) ->

    it "should give simple description", ->
      test.desc options
    it "should give simple list description", ->
      test.desc
        type: 'array'
        entries:
          type: 'integer'
    it "should give complex list description", ->
      test.desc
        type: 'array'
        entries: [
          type: 'integer'
        ,
          type: 'string'
        ]

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate simple list", ->
      test.selfcheck
        type: 'array'
        entries:
          type: 'integer'
    it "should validate complex list", ->
      test.selfcheck
        type: 'array'
        entries: [
          type: 'integer'
        ,
          type: 'string'
        ]
