require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'
path = require 'path'

describe "File", ->

  schema = null
  beforeEach ->
    schema =
      type: 'file'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 'myfile.txt'
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match filenames", (cb) ->
      test.same schema, [
        'myfile.txt'
        'anywhere/myfile.txt'
        '/anywhere'
      ], cb

    it "should sanitize file paths", (cb) ->
      test.equal schema, [
        ['/anywhere/', '/anywhere']
        ['//anywhere', '/anywhere']
        ['/anywhere/../anywhere', '/anywhere']
      ], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, [1, null, [], (new Error '????'), {}], cb

  describe "option check", ->

    it "should support resolve option", (cb) ->
      schema.resolve = true
      test.equal schema, [
        ['myfile.txt', path.resolve '.', 'myfile.txt']
      ], cb

    it "should support resolve and basedir option", (cb) ->
      schema.basedir = '/home/mydir/test'
      schema.resolve = true
      test.equal schema, [
        ['myfile.txt', '/home/mydir/test/myfile.txt']
        ['./myfile.txt', '/home/mydir/test/myfile.txt']
        ['../myfile.txt', '/home/mydir/myfile.txt']
        ['/myfile.txt', '/myfile.txt']
      ], cb

    it "should support find option", (cb) ->
      @timeout 10000
      schema.find = ['.']
      test.equal schema, [
        ['file.js', 'lib/type/file.js']
      ], cb

    it "should support find and resolve option", (cb) ->
      @timeout 10000
      schema.find = ['.']
      schema.resolve = true
      test.equal schema, [
        ['file.js', path.resolve '.', 'lib/type/file.js']
      ], cb

    it "should support find option with dynamic values", (cb) ->
      @timeout 10000
      schema.find = -> ['.']
      test.equal schema, [
        ['file.js', 'lib/type/file.js']
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'file'
        optional: true
        default: 'myfile.txt'
        basedir: '/anywhere'
        exists: true
        filetype: 'file'
      , cb

    it "should give complete find description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'file'
        optional: true
        default: 'myfile.txt'
        basedir: '/anywhere'
        find: ['.']
        filetype: 'file'
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb
    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'file'
        optional: true
        default: 'myfile.txt'
        basedir: '/anywhere'
        find: ['.']
        exists: true
        filetype: 'file'
      , cb
