# Validator
# =================================================

debug = require('debug')('validator')

helper = require './helper'

# Check if value is valid
# -------------------------------------------------
# This will check the given value against the checks defined in the options.
# It will only give a value of true or false to the callback.
exports.is = (source, value, options, cb) ->
  not exports.check source, value, options, (err) ->
    cb not err?
    not err?

# Check value and sanitize
# -------------------------------------------------
# This will check the given value, sanitize it and return the new value or an
# Error to the callback.
exports.check = (source, value, options, cb) ->
  debug "Check #{source}..."
  helper.getType(options.check).check source, value, options, cb

# Check if value is valid
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (options) ->
  helper.getType(options.check).describe options
