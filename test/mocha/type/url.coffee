test = require '../../test'
### eslint-env node, mocha ###

describe.only "URL", ->

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
