require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "Integer", ->

  options = null

  beforeEach ->
    options =
      type: 'integer'

  describe "sync check", ->

    it "should match integer objects", ->
      test.equal options, 1, 1
      test.equal options, -12, -12
      test.equal options, '3678', 3678
    it "should fail on other objects", ->
      test.fail options, 15.3
      test.fail options, ''
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'integer'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support sanitize option", ->
      options =
        type: 'integer'
        sanitize: true
      test.equal options, 'go4now', 4
      test.equal options, '15kg', 15
      test.equal options, '-18.6%', -18
    it "should fail with sanitize option", ->
      options =
        type: 'integer'
        sanitize: true
      test.fail options, 'gonow'
      test.fail options, 'one'
    it "should support round option", ->
      options =
        type: 'integer'
        sanitize: true
        round: true
      test.equal options, 13.5, 14
      test.equal options, -9.49, -9
      test.equal options, '+18.6', 19
    it "should support round (floor) option", ->
      options =
        type: 'integer'
        sanitize: true
        round: 'floor'
      test.equal options, 13.5, 13
      test.equal options, -9.49, -10
      test.equal options, '+18.6', 18
    it "should support round (ceil) option", ->
      options =
        type: 'integer'
        sanitize: true
        round: 'ceil'
      test.equal options, 13.5, 14
      test.equal options, -9.49, -9
      test.equal options, '+18.2', 19
    it "should support min option", ->
      options =
        type: 'integer'
        min: -2
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
    it "should fail for min option", ->
      options =
        type: 'integer'
        min: -2
      test.fail options, -8
    it "should support max option", ->
      options =
        type: 'integer'
        max: 12
      test.equal options, 6, 6
      test.equal options, 0, 0
      test.equal options, -2, -2
      test.equal options, 12, 12
    it "should fail for max option", ->
      options =
        type: 'integer'
        max: -2
      test.fail options, 100
      test.fail options, -1
    it "should support type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
      test.equal options, 6, 6
      test.equal options, -128, -128
      test.equal options, 127, 127
    it "should fail for type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
      test.fail options, 128
      test.fail options, -129
    it "should support type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
        unsigned: true
      test.equal options, 254, 254
      test.equal options, 0, 0
    it "should fail for type option", ->
      options =
        type: 'integer'
        inttype: 'byte'
        unsigned: true
      test.fail options, 256
      test.fail options, -1

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'integer'
        optional: true
        default: 5
        sanitize: true
        round: 'floor'
        inttype: 'byte'
        unsigned: true
        min: 2
        max: 20

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'integer'
        optional: true
        default: 5
        sanitize: true
        round: 'floor'
        inttype: 'byte'
        unsigned: true
        min: 2
        max: 20
