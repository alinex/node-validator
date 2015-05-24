# Validator
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator')
chalk = require 'chalk'
util = require 'util'
# internal classes and helper
check = require './check'


# Create human readable description
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (spec) ->
  check.describe spec

# Check value and sanitize
# -------------------------------------------------
# This will check the given value, sanitize it and return the new value or an
# Error to the callback.
exports.check = (spec, cb) ->
  # check the given data
  throw new Error "No callback method given" unless typeof cb is 'function'
  return cb new Error "No schema definition given" unless spec.schema
  # optimize data
  spec.debug = chalk.grey spec.name ? 'value'
  # run the check
  debug "#{spec.debug} check as #{spec.schema.title ? spec.schema.type}"
  check.run spec, (err, result) ->
    if err
      debug "#{spec.debug} failed with: #{err.message}"
    else
      debug "#{spec.debug} succeeded with: #{util.inspect result}"
    cb err, result

# Check validation rules
# -------------------------------------------------
# This may be used in tests to check the validator check options if they are valid.
exports.selfcheck = (spec, cb) ->
  check.selfcheck spec, cb
