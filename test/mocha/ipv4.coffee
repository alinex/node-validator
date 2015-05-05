require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

describe "IP version 4", ->

  options = null

  beforeEach ->
    options =
      type: 'ipv4'

  describe "sync check", ->

    it "should match normal adresses", ->
      test.equal options, '127.0.0.1', '127.0.0.1'
      test.equal options, '192.012.001.001', '192.012.001.001'
    it "should fail on other objects", ->
      test.fail options, 1
      test.fail options, null
      test.fail options, []
      test.fail options, (new Error '????')
      test.fail options, {}
    it "should fail on wrong addresses", ->
      test.fail options, '300.92.16.2'
      test.fail options, '192.168.5'
      test.fail options, 'ffff::'
      test.fail options, '12.0.0.0.1'
    it "should support optional option", ->
      options =
        type: 'ipv4'
        optional: true
      test.equal options, null, null
      test.equal options, undefined, null
    it "should support default option", ->
      options =
        type: 'ipv4'
        optional: true
        default: '127.0.0.1'
      test.equal options, null, '127.0.0.1'
      test.equal options, undefined, '127.0.0.1'
    it "should support short format", ->
      options =
        type: 'ipv4'
        format: 'short'
      test.equal options, '127.0.0.1', '127.0.0.1'
      test.equal options, '127.000.000.001', '127.0.0.1'
    it "should support long format", ->
      options =
        type: 'ipv4'
        format: 'long'
      test.equal options, '127.0.0.1', '127.000.000.001'
      test.equal options, '127.000.000.001', '127.000.000.001'

    it.only "should support deny range", ->
      options =
        type: 'ipv4'
        deny: 'private'
      test.fail options, '127.0.0.1'
      test.fail options, '172.16.0.1'
      test.fail options, '192.168.15.1'
      test.fail options, '10.8.0.1'
      test.equal options, '217.122.0.1', '217.122.0.1'

    it.only "should support allow range", ->
      options =
        type: 'ipv4'
        allow: 'private'
      test.fail options, '217.122.0.1'
      test.equal options, '127.0.0.1', '127.0.0.1'
      test.equal options, '172.16.0.1', '172.16.0.1'
      test.equal options, '192.168.15.1', '192.168.15.1'
      test.equal options, '10.8.0.1', '10.8.0.1'

    it.only "should support deny with allow range", ->
      options =
        type: 'ipv4'
        deny: 'private'
        allow: '127.0.0.1/8'
      test.fail options, '172.16.0.1'
      test.fail options, '192.168.15.1'
      test.fail options, '10.8.0.1'
      test.equal options, '127.0.0.1', '127.0.0.1'
      test.equal options, '217.122.0.1', '217.122.0.1'

  describe "description", ->

    it "should give simple description", ->
      test.desc options
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'ipv4'
        optional: true
        default: '127.0.0.1'
        format: 'short'
        deny: 'private'
        allow: '192.168.1.0/24'

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck options
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'ipv4'
        optional: true
        default: '127.0.0.1'
        format: 'short'
        deny: 'private'
        allow: '192.168.1.0/24'
