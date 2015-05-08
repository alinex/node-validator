require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

describe "reference values", ->

  options = null

  beforeEach ->
    options =
      type: 'object'
      entries:
        one:
          type: 'integer'
          min: 1
        two:
          type: 'integer'
          min: 2
        three:
          type: 'integer'
          min: 3

  describe "sync check", ->

    it "should work normally on objects", ->
      test.same options, { one:1, two:2, three:3 }
      test.same options, { one:6, two:5, three:4 }

    it.only "should fail on absolute reference", ->
      options.entries.two.min =
        reference: 'absolute'
        source: 'one'
      test.fail options, { one:6, two:5, three:4 }

    it "should support relative reference", ->
      options.entries.two.min =
        reference: 'relative'
        source: '<one'
      test.same options, { one:1, two:2, three:3 }
    it "should fail on relative reference", ->
      options.entries.two.min =
        reference: 'relative'
        source: '<one'
      test.fail options, { one:6, two:5, three:4 }

    it "should support external reference", ->
      options.entries.two.min =
        reference: 'external'
        source: 'test.min'
      test.same options, { one:1, two:2, three:3 }, { test: {min:2} }
    it "should fail on external reference", ->
      options.entries.two.min =
        reference: 'external'
        source: 'test.min'
      test.fail options, { one:6, two:5, three:4 }, { test: {min:6} }

    it "should support operation in reference", ->
      options.entries.two.min =
        reference: 'absolute'
        source: 'one'
        operation: (val) -> val + 1
      test.same options, { one:1, two:2, three:3 }

    it "should fail after operation in reference", ->
      options.entries.two.min =
        reference: 'absolute'
        source: 'one'
        operation: (val) -> val + 4
      test.fail options, { one:1, two:2, three:3 }

  describe "async check", ->

    it "should work normally on objects", (cb) ->
      async.series [
        (cb) -> test.same options, { one:1, two:2, three:3 }, cb
        (cb) -> test.same options, { one:6, two:5, three:4 }, cb
      ], cb

    it "should support absolute reference", (cb) ->
      options.entries.two.min =
        reference: 'absolute'
        source: 'one'
      async.series [
        (cb) -> test.same options, { one:1, two:2, three:3 }, cb
      ], cb
    it "should fail on absolute reference", (cb) ->
      options.entries.two.min =
        reference: 'absolute'
        source: 'one'
      async.series [
        (cb) -> test.fail options, { one:6, two:5, three:4 }, cb
      ], cb

    it "should support relative reference", (cb) ->
      options.entries.two.min =
        reference: 'relative'
        source: '<one'
      async.series [
        (cb) -> test.same options, { one:1, two:2, three:3 }, cb
      ], cb
    it "should fail on relative reference", (cb) ->
      options.entries.two.min =
        reference: 'relative'
        source: '<one'
      async.series [
        (cb) -> test.fail options, { one:6, two:5, three:4 }, cb
      ], cb

    it "should support external reference", (cb) ->
      options.entries.two.min =
        reference: 'external'
        source: 'test.min'
      async.series [
        (cb) -> test.same options, { one:1, two:2, three:3 }, { test: {min:2} }, cb
      ], cb
    it "should fail on external reference", (cb) ->
      options.entries.two.min =
        reference: 'external'
        source: 'test.min'
      async.series [
        (cb) -> test.fail options, { one:6, two:5, three:4 }, { test: {min:6} }, cb
      ], cb
