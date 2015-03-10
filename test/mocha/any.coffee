require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

describe "Any", ->

  options = null

  beforeEach ->
    options =
      type: 'any'
      entries: [
        type: 'integer'
      ,
        type: 'boolean'
      ]

  describe "sync check", ->

    it "should match any selection", ->
      test.true options, true
      test.false options, false
      test.equal options, 1, 1
      test.equal options, -12, -12
      test.equal options, '3678', 3678
    it "should fail for any selection", ->
      test.fail options, 15.3
      test.fail options, ''
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}

  describe "async check", ->

    it "should match any selection", (cb) ->
      async.series [
        (cb) -> test.true options, true, cb
        (cb) -> test.false options, false, cb
        (cb) -> test.equal options, 1, 1, cb
        (cb) -> test.equal options, -12, -12, cb
        (cb) -> test.equal options, '3678', 3678, cb
      ], cb
    it "should fail for any selection", (cb) ->
      async.series [
        (cb) -> test.fail options, 15.3, cb
        (cb) -> test.fail options, '', cb
        (cb) -> test.fail options, [], cb
        (cb) -> test.fail options, (new Error '????'), cb
        (cb) -> test.fail options, {}, cb
      ], cb

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'any'
        entries: [
          type: 'integer'
        ,
          type: 'string'
        ]

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'any'
        entries: [
          type: 'integer'
        ,
          type: 'string'
        ]

