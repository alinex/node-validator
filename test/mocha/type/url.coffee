test = require '../../test'
### eslint-env node, mocha ###

describe "URL", ->

  schema = null
  beforeEach ->
    schema =
      type: 'url'

  describe "check", ->

    it "should support optional option", (cb) ->
      schema.optional = true
      test.undefined schema, [null, undefined], cb

    it "should support default option", (cb) ->
      schema.optional = true
      schema.default = 'http://alinex.de/'
      test.equal schema, [
        [null, schema.default]
        [undefined, schema.default]
      ], cb

  describe "simple check", ->

    it "should match normal url", (cb) ->
      test.same schema, ['http://alinex.github.io/node-validator/README.md.html#regexp'], cb

    it "should fail on other elements", (cb) ->
      test.fail schema, [null, [], (new Error '????'), {}], cb

  describe "options", ->

    it "should normalize url", (cb) ->
      test.equal schema, [
        ['http://alinex.de', 'http://alinex.de/']
      ], cb

    it "should make url absolute", (cb) ->
      schema.toAbsoluteBase = 'http://alinex.de/doc/'
      test.equal schema, [
        ['index.html', 'http://alinex.de/doc/index.html']
      ], cb

    it "should remove query and hash params", (cb) ->
      schema.removeQuery = true
      test.equal schema, [
        ['http://alinex.de/?search=test#page1', 'http://alinex.de/']
      ], cb

    it "should allow correct hosts", (cb) ->
      schema.hostsAllowed = /\.de$/
      test.equal schema, [
        ['http://alinex.de/?search=test#page1', 'http://alinex.de/?search=test#page1']
      ], cb
    it "should fail on not allowed host", (cb) ->
      schema.hostsAllowed = /\.com$/
      test.fail schema, ['http://alinex.de/'], cb

    it "should work if host not disallowed", (cb) ->
      schema.hostsDenied = /\.com$/
      test.equal schema, [
        ['http://alinex.de/?search=test#page1', 'http://alinex.de/?search=test#page1']
      ], cb
    it "should disallow hosts", (cb) ->
      schema.hostsDenied = /\.de$/
      test.fail schema, ['http://alinex.de/'], cb

    it "should work for listed protocols", (cb) ->
      schema.allowProtocols = ['http']
      test.equal schema, [
        ['http://alinex.de/?search=test#page1', 'http://alinex.de/?search=test#page1']
      ], cb
    it "should fail on not allowed protocols", (cb) ->
      schema.allowProtocols = ['http']
      test.fail schema, ['https://alinex.de/'], cb

    it "should allow relative urls", (cb) ->
      schema.allowRelative = true
      test.same schema, ['index.html'], cb
    it "should disallow relative urls", (cb) ->
      schema.allowRelative = false
      test.fail schema, ['index.html'], cb

#        allowProtocols: ['http']
#        allowRelative: true

  describe "description", ->

    it "should give simple description", (cb) ->
      test.describe schema, cb

    it "should give complete description", (cb) ->
      test.describe
        title: 'test'
        description: 'Some test rules'
        type: 'url'
        optional: true
        default: 'nix'
        toAbsoluteBase: 'http://alinex.de'
        removeQuery: true
        hostsAllowed: ['alinex.de']
        hostsDenied: [/google/]
        allowProtocols: ['http']
        allowRelative: true
      , cb

  describe "selfcheck", ->

    it "should validate simple options", (cb) ->
      test.selfcheck schema, cb

    it "should validate complete options", (cb) ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'url'
        optional: true
        default: 'nix'
        toAbsoluteBase: 'http://alinex.de'
        removeQuery: true
        hostsAllowed: ['alinex.de']
        hostsDenied: [/google/]
        allowProtocols: ['http']
        allowRelative: true
      , cb
