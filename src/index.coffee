# Validator
# =================================================

# Node modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
# internal classes and helper
ValidatorCheck = require './check'


# Check if value is valid
# -------------------------------------------------
# This will check the given value against the checks defined in the options.
# It will only give a value of true or false to the callback.
exports.is = (source, options, value, data = {}, cb) ->
  if not cb? and typeof data is 'function'
    cb = data
    data = {}
  check = new ValidatorCheck source, options, value, data
  unless cb?
    return not check.run() typeof Error
  check.run (err) ->
    cb err?


# Check value and sanitize
# -------------------------------------------------
# This will check the given value, sanitize it and return the new value or an
# Error to the callback.
exports.check = (source, options, value, data = {}, cb) ->
  if not cb? and typeof data is 'function'
    cb = data
    data = {}
  check = new ValidatorCheck source, options, value, data
  unless cb?
    return check.sync()
  check.async cb


# Create human readable description
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (options) ->
  ValidatorCheck.describe options


# Check validation rules
# -------------------------------------------------
# This may be used in tests to check the validator check options if they are valid.
exports.selfcheck = (name, rules) ->
  types = []
  for file in fs.readdirSync path.join __dirname, 'type'
    if path.extname(file) is '.js'
      types.push path.basename file, path.extname file
  exports.check name,
    type: 'object'
    mandatoryKeys: ['type']
    entries:
      type:
        type: 'string'
        values: types
  , rules
  # Check type specific
  lib = require "./type/#{rules.type}"
  lib.selfcheck name, rules
