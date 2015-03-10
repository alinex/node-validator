require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

describe "Byte", ->

  options = null

  beforeEach ->
    options =
      type: 'byte'

  describe "sync check", ->

    it "should match integers", ->
      test.equal options, 18, 18
      test.equal options, 0, 0
      test.equal options, 118371, 118371
    it "should match string definition", ->
      test.equal options, '12', 12
      test.equal options, '100B', 100
      test.equal options, '100 B', 100
    it "should match prefix definition", ->
      test.equal options, '1kB', 1024
      test.equal options, '1KiB', 1024
      test.equal options, '1MB', 1024*1024
      test.equal options, '1MiB', 1024*1024
      test.equal options, '1GB', 1024*1024*1024
      test.equal options, '1GiB', 1024*1024*1024
    it "should fail on other objects", ->
      test.fail options, 'hello'
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should support optional option", ->
      options =
        type: 'byte'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support min option", ->
      options =
        type: 'byte'
        min: 100
      test.equal options, 600, 600
      test.equal options, 100, 100
    it "should fail for min option", ->
      options =
        type: 'byte'
        min: 100
      test.fail options, 60
      test.fail options, -8
    it "should support max option", ->
      options =
        type: 'byte'
        max: 100
      test.equal options, 60, 60
      test.equal options, 0, 0
    it "should fail for max option", ->
      options =
        type: 'byte'
        max: 100
      test.fail options, 1000
      test.fail options, -1

  describe "derived bps", ->

    it "should match string definition", ->
      test.equal options, '100bps', 100
    it "should match prefix definition", ->
      test.equal options, '1kbps', 1024
      test.equal options, '1Mbps', 1024*1024
      test.equal options, '1Gbps', 1024*1024*1024

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'interval'
        optional: true
        default: 5
        min: 2
        max: 20

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'interval'
        optional: true
        default: 5
        min: 2
        max: 20
