chai = require 'chai'
expect = chai.expect
async = require 'alinex-async'
chalk = require 'chalk'

validator = require '../lib/index'

exports.describe = (schema) ->
  desc = validator.describe
    schema: schema
  expect(desc).to.be.a 'string'
  expect(desc).to.have.length.of.at.least 10
  console.log chalk.yellow desc

exports.true = (schema, values, cb) ->
  num = 0
  async.each values, (value, cb) ->
    validator.check
      name: "test-#{++num}"
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
      name: "test-#{++num}"
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
      name: "test-#{++num}"
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
      name: "test-#{++num}"
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
      name: "test-#{++num}"
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
      name: "test-#{++num}"
      schema: schema
      value: value
    , (err, result) ->
      expect(err, 'error').to.not.exist
      expect(result, 'result').to.equal goal
      cb()
  , cb

exports.selfcheck = (schema, cb) ->
  validator.selfcheck 'test', schema, (err, result) ->
    expect(err, 'error').to.not.exist
    expect(result, 'result').to.exist
    cb()
