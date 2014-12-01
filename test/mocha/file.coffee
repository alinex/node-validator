require('alinex-error').install()
async = require 'async'

test = require '../test'

describe "File", ->

  options = null

  beforeEach ->
    options =
      type: 'file'

  describe "sync check", ->

    it "should match normal filename", ->
      test.same options, 'myfile.txt'
      test.same options, 'anywhere/myfile.txt'
      test.same options, '/anywhere/myfile.txt'
      test.same options, '/anywhere'
      test.equal options, '/anywhere/', '/anywhere'
    it "should fail on other objects", ->
      test.fail options, 1
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'file'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support default option", ->
      options =
        type: 'file'
        optional: true
        default: 'myfile.txt'
      test.equal options, null, 'myfile.txt'
      test.equal options, undefined, 'myfile.txt'

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'file'
        optional: true
        default: 'myfile.txt'
        basedir: '/anywhere'
        exists: true
        filetype: 'file'
    it "should give complete find description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'file'
        optional: true
        default: 'myfile.txt'
        basedir: '/anywhere'
        find: true
        filetype: 'file'

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'file'
        optional: true
        default: 'myfile.txt'
        basedir: '/anywhere'
        find: true
        exists: true
        filetype: 'file'
