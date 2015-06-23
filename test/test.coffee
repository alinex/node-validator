chai = require 'chai'
expect = chai.expect
async = require 'alinex-async'
chalk = require 'chalk'

validator = require '../lib/index'

exports.describe = (schema, cb) ->
  validator.describe
    schema: schema
  , (err, text) ->
    expect(err, 'error').to.not.exist
    expect(text).to.be.a 'string'
    expect(text).to.have.length.of.at.least 8
    console.log chalk.yellow text
    cb()

exports.describeFail = (schema, cb) ->
  validator.describe
    schema: schema
  , (err, text) ->
    expect(err, 'error').to.exist
    cb()

exports.true = (schema, values, cb) ->
  num = 0
  async.each values, (value, cb) ->
    validator.check
      name: "true-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.be.true
      cb()
  , cb

exports.false = (schema, values, cb) ->
  num = 0
  async.each values, (value, cb) ->
    validator.check
      name: "false-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.be.false
      cb()
  , cb

exports.fail = (schema, values, cb) ->
  num = 0
  async.each values, (value, cb) ->
    validator.check
      name: "fail-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.exist
      expect(result, 'result').to.not.exist
      cb()
  , cb

exports.undefined = (schema, values, cb) ->
  num = 0
  async.each values, (value, cb) ->
    validator.check
      name: "undefined-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.be.undefined
      cb()
  , cb

exports.same = (schema, values, cb) ->
  num = 0
  async.each values, (value, cb) ->
    validator.check
      name: "same-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.equal value
      cb()
  , cb

exports.equal = (schema, values, cb) ->
  num = 0
  async.each values, ([value, goal], cb) ->
    validator.check
      name: "equal-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.deep.equal goal
      cb()
  , cb

exports.function = (schema, values, cb) ->
  num = 0
  async.each values, ([value, params, goal], cb) ->
    validator.check
      name: "equal-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.be.a 'function'
      expect(result params, 'test function').to.deep.equal goal
      cb()
  , cb

exports.selfcheck = (schema, cb) ->
  validator.selfcheck schema, cb
