###
Controller - API Usage
=================================================
To make all checks and also I/O specific optimizations available these checks
are primarily asynchronous. While there are also synchronous variants available
to the outside for simplicity better use the asynchronous ones because the other
uses more cpu performance.
###


# Node modules
# -------------------------------------------------
debug = require('debug')('validator')
chalk = require 'chalk'
deasync = require 'deasync'
# alinex packages
util = require 'alinex-util'
# internal classes and helper
Worker = require './helper/worker'


# External Methods
# -------------------------------------------------

###
This will directly return the description of how the value has to be.

@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
- `dir` - `String` set to base directory for file relative file paths
@param {function(Error, String)} cb callback with descriptive text or an error if
something went wrong
###
exports.describe = (spec, cb) ->
  name = spec.name ? 'value'
  schema = spec.
  value = util.clone spec.value
  worker = new Worker name, schema, spec.context, spec.dir
  worker.describe cb

###
This will directly return the description of how the value has to be.

@name describeSync()
@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
- `dir` - `String` set to base directory for file relative file paths
@return {String} descriptive text
@throw {Error} if something went wrong
###
exports.describeSync = deasync exports.describe

###
This will check the given value, sanitize it and return the new value or an
Error to the callback.

@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
- `dir` - `String` set to base directory for file relative file paths
- `value` - original value (not changed)
@param {function(Error, Mixed)} cb callback with optimized value or an error if
something is wrong with the value as far as possible to sanitize
###
exports.check = (spec, cb) ->
  # check the given data
  throw new Error "No callback method given" unless typeof cb is 'function'
  return cb new Error "No schema definition given" unless spec.schema
  # optimize data
  name = spec.name ? 'value'
  schema = util.clone spec.schema
  schema.title ?= 'reference'
  debug "#{name} initialize to check as #{schema.title}"
  value = util.clone spec.value
  # instantiate new object
  worker = new Worker name, schema, spec.context, spec.dir, value
  # run the check
  worker.check (err) ->
    debug if err
      "#{name}: failed with: #{err.message}"
    else
      "#{name}: succeeded"
    cb err, worker.value

###
This will check the given value, sanitize it and return the new value or an
Error to the callback.

@name checkSync()
@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
- `dir` - `String` set to base directory for file relative file paths
- `value` - original value (not changed)
@return {String} optimized value
@throw {Error} if something went wrong
###
exports.checkSync = deasync exports.check

###
This may be used in tests to check the validator check options if they are valid.

@param {Object} schema structure to check
@param {function(Error, Mixed)} cb callback with the checked schema or an error if
something is wrong
###
exports.selfcheck = (schema, cb) ->
  check.selfcheck schema, cb

###
This may be used in tests to check the validator check options if they are valid.

@name selfcheckSync()
@param {Object} schema structure to check
@return {String} checked schema
@throw {Error} if something went wrong
###
exports.selfcheckSync = deasync exports.selfcheck
