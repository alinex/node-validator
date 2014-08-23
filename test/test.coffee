chai = require 'chai'
expect = chai.expect

validator = require '../lib/index'

exports.true = (options, value, cb) ->
  # sync version
  unless cb?
    return expect validator.check('test', options, value)
    , value
    .to.be.true
  # async version
  validator.check 'test', options, value, (err, result) ->
    expect(err, value).to.not.exist
    expect(result, value).to.be.true
    cb()

exports.false = (options, value, cb) ->
  # sync version
  unless cb?
    return expect validator.check('test', options, value)
    , value
    .to.be.false
  # async version
  validator.check 'test', options, value, (err, result) ->
    expect(err, value).to.not.exist
    expect(result, value).to.be.false
    cb()

exports.fail = (options, value, data, cb) ->
  if not cb? and typeof data is 'function'
    cb = data
    data = {}
  # sync version
  unless cb?
    return expect ->
      validator.check('test', options, value, data)
    .to.throw Error
  # async version
  validator.check 'test', options, value, data, (err, result) ->
    expect(err, value).to.exist
    expect(err, value).to.be.an.instanceof Error
    cb()

exports.equal = (options, value, goal, cb) ->
  # sync version
  unless cb?
    return expect validator.check('test', options, value)
    , value
    .to.equal goal
  # async version
  validator.check 'test', options, value, (err, result) ->
    expect(err, value).to.not.exist
    expect(result, value).to.equal goal
    cb()

exports.same = (options, value, data, cb) ->
  if not cb? and typeof data is 'function'
    cb = data
    data = {}
  exports.deep options, value, value, data, cb

exports.deep = (options, value, goal, data, cb) ->
  if not cb? and typeof data is 'function'
    cb = data
    data = {}
  # sync version
  unless cb?
    return expect validator.check('test', options, value, data)
    , value
    .to.deep.equal goal
  # async version
  validator.check 'test', options, value, data, (err, result) ->
    expect(err, value).to.not.exist
    expect(result, value).to.deep.equal goal
    cb()

exports.instance = (options, value, goal, cb) ->
  # sync version
  unless cb?
    return expect validator.check('test', options, value)
    , value
    .to.be.an.instanceof goal
  # async version
  validator.check 'test', options, value, (err, result) ->
    expect(err, value).to.not.exist
    expect(result, value).to.be.an.instanceof goal
    cb()

exports.desc = (options) ->
  desc = validator.describe options
  expect(desc).to.be.a 'string'
  expect(desc).to.have.length.of.at.least 10

