test = require '../../test'
path = require 'path'
{exec} = require 'child_process'
### eslint-env node, mocha ###

describe.skip "File", ->

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
    @timeout 14000

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
      schema.find = ['.']
      test.equal schema, [
        ['file.js', 'lib/type/file.js']
      ], cb

    it "should support find and resolve option", (cb) ->
      schema.find = ['.']
      schema.resolve = true
      test.equal schema, [
        ['file.js', path.resolve '.', 'lib/type/file.js']
      ], cb

    it "should support find option with dynamic values", (cb) ->
      schema.find = -> ['.']
      test.equal schema, [
        ['file.js', 'lib/type/file.js']
      ], cb

    it "should fail for empty find list", (cb) ->
      schema.find = -> []
      test.fail schema, ['file.js'], cb

    it "should fail for empty find result", (cb) ->
      schema.find = -> ['.']
      test.fail schema, ['not-to-be-found-anywhere.js'], cb

    it "should exist as file", (cb) ->
      schema.exists = true
      test.same schema, [
        'test/test.coffee'
        'test/data/poem'
        'test'
      ], ->
        test.fail schema, [
          'myfile.txt'
          'anywhere/myfile.txt'
          '/anywhere'
        ], cb

    it "should check for filetype: file", (cb) ->
      schema.filetype = 'f'
      test.same schema, [
        'test/test.coffee'
        'test/data/poem'
      ], ->
        test.fail schema, [
          'test'
        ], cb

    it "should check for filetype: dir", (cb) ->
      schema.filetype = 'd'
      test.same schema, [
        'test'
      ], ->
        test.fail schema, [
          'test/test.coffee'
          'test/data/poem'
        ], cb

    it "should check for filetype: link", (cb) ->
      schema.filetype = 'l'
      test.same schema, [
        'test/data/poem.link'
      ], ->
        test.fail schema, [
          'test/test.coffee'
          'test/data/poem'
          'test'
        ], cb

    it "should check for filetype: fifo", (cb) ->
      exec 'mkfifo test/data/fifo', ->
        schema.filetype = 'fifo'
        test.same schema, [
          'test/data/fifo'
        ], ->
          exec 'rm test/data/fifo', ->
            test.fail schema, [
              'test/test.coffee'
              'test/data/poem'
              'test'
            ], cb

    it "should check for filetype: socket", (cb) ->
      schema.filetype = 'socket'
      test.same schema, [
        '/run/udev/control'
      ], ->
        test.fail schema, [
          'test/test.coffee'
          'test/data/poem'
          'test'
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
        resolve: true
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
        resolve: true
      , cb
