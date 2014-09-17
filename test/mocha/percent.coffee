require('alinex-error').install()
async = require 'async'

test = require '../test'

process.setMaxListeners 0

describe "Percent", ->

  options = null

  beforeEach ->
    options =
      type: 'percent'

  describe "sync check", ->

    it "should match number objects", ->
      test.equal options, 18, 18
      test.equal options, 0.4, 0.4
      test.equal options, -0.02, -0.02
    it "should match string definition", ->
      test.equal options, '1800%', 18
      test.equal options, '40%', 0.4
      test.equal options, '-2%', -0.02
      test.equal options, '3.8%', 0.038
    it "should fail on other objects", ->
      test.fail options, 'hello'
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'percent'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support round option", ->
      options =
        type: 'percent'
        round: true
      test.equal options, 1.445, 1.45
      test.equal options, '+18.56', 18.56
    it "should support min option", ->
      options =
        type: 'percent'
        min: 0
      test.equal options, 0.06, 0.06
      test.equal options, 0, 0
    it "should fail for min option", ->
      options =
        type: 'percent'
        min: 0
      test.fail options, -8
    it "should support max option", ->
      options =
        type: 'percent'
        max: 1
      test.equal options, 1, 1
      test.equal options, '100%', 1
    it "should fail for max option", ->
      options =
        type: 'percent'
        max: 1
      test.fail options, 10
      test.fail options, '110%'

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'percent'
        optional: true
        default: 5
        round: 2
        min: 2
        max: 200

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'percent'
        optional: true
        default: 5
        round: 2
        min: 2
        max: 200
