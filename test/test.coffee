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

exports.fail = (options, value, cb) ->
  # sync version
  unless cb?
    return expect validator.check('test', options, value)
    , value
    .to.be.an.instanceof Error
  # async version
  validator.check 'test', options, value, (err, result) ->
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

exports.same = (options, value, cb) ->
  exports.deep options, value, value, cb

exports.deep = (options, value, goal, cb) ->
  # sync version
  unless cb?
    return expect validator.check('test', options, value)
    , value
    .to.deep.equal goal
  # async version
  validator.check 'test', options, value, (err, result) ->
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

