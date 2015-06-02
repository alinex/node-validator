require('alinex-error').install()
async = require 'alinex-async'

test = require '../../test'

describe "IP Address", ->

  schema = null
  beforeEach ->
    schema =
      type: 'ipaddr'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = '127.0.0.1'
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match normal adresses", (cb) ->
      test.same schema, ['127.0.0.1', '192.12.1.1', 'ffff::'], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, [1, null, [], (new Error '????'), { }], cb

    it "should fail on incorrect addresses", (cb) ->
      test.fail schema, ['300.92.16.2', '192.168.5', '12.0.0.0.1'], cb

  describe "options check", ->

    it "should limit to ipv4 addresses", (cb) ->
      schema.version = 'ipv4'
      test.same schema, ['127.0.0.1'], ->
        test.fail schema, ['ffff::'], cb

    it "should limit to ipv6 addresses", (cb) ->
      schema.version = 'ipv6'
      test.same schema, ['ffff::'], ->
        test.fail schema, ['127.0.0.1'], cb

    it "should support deny range", (cb) ->
      schema.deny = [
        '216.0.0.1/8'
        'private'
      ]
      test.same schema, ['217.122.0.1'], ->
        test.fail schema, ['172.16.0.1', '192.168.15.1','10.8.0.1',
        '216.122.0.1'], cb

    it "should support allow range", (cb) ->
      schema.allow = [
        '216.0.0.1/8'
        'private'
      ]
      test.same schema, ['172.16.0.1', '192.168.15.1', '10.8.0.1',
      '216.122.0.1'], ->
        test.fail schema, ['217.122.0.1'], cb

    it "should support deny with allow range", (cb) ->
      schema.deny = ['private']
      schema.allow = ['192.168.12.1/24']
      test.same schema, ['192.168.12.20', '217.122.0.1'], ->
        test.fail schema, ['172.16.0.1', '192.168.15.1', '10.8.0.1'], cb

    it "should support short format", (cb) ->
      schema.format = 'short'
      test.equal schema, [
        ['127.0.0.1', '127.0.0.1']
        ['127.000.000.001', '127.0.0.1']
        ['ffff:0:0:0:0:0:0:1', 'ffff::1']
      ], cb

    it "should support long format", (cb) ->
      schema.format = 'long'
      test.equal schema, [
        ['127.0.0.1', '127.0.0.1']
        ['127.000.000.001', '127.0.0.1']
        ['ffff:0:0:0:0:0:0:1', 'ffff:0:0:0:0:0:0:1']
        ['ffff::1', 'ffff:0:0:0:0:0:0:1']
      ], cb

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'ipaddr'
        optional: true
        default: '127.0.0.1'
        version: 'ipv4'
        format: 'short'
        deny: ['private']
        allow: ['192.168.1.0/24']
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'ipaddr'
        optional: true
        default: '127.0.0.1'
        version: 'ipv4'
        format: 'short'
        deny: ['private']
        allow: ['192.168.1.0/24']
      , cb
