require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

describe "Hostname", ->

  options = null

  beforeEach ->
    options =
      type: 'hostname'

  describe "sync check", ->

    it "should match normal names", ->
      test.equal options, 'localhost', 'localhost'
      test.equal options, 'mypc', 'mypc'
      test.equal options, 'my-pc', 'my-pc'
    it "should fail on other objects", ->
      test.fail options, 1
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'hostname'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support default option", ->
      options =
        type: 'hostname'
        optional: true
        default: 'localhost'
      test.equal options, null, 'localhost'
      test.equal options, undefined, 'localhost'

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'hostname'
        optional: true
        default: 'nix'

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'hostname'
        optional: true
        default: 'nix'
