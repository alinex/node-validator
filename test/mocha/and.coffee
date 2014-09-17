require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "And", ->

  options = null

  beforeEach ->
    options =
      type: 'and'
      entries: [
        type: 'percent'
      ,
        type: 'integer'
      ]

  describe "sync check", ->

    it "should match and selection", ->
      test.equal options, 1, 1
      test.equal options, -12, -12
      test.equal options, '3678', 3678
    it "should fail for and selection", ->
      test.fail options, ''
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}

  describe "async check", ->

    it "should match and selection", (cb) ->
      async.series [
        (cb) -> test.equal options, 1, 1, cb
        (cb) -> test.equal options, -12, -12, cb
        (cb) -> test.equal options, '3678', 3678, cb
      ], cb
    it "should fail for and selection", (cb) ->
      async.series [
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
        type: 'and'
        entries: [
          type: 'percent'
        ,
          type: 'integer'
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

