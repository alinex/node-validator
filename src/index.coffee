# Validator
# =================================================

debug = require('debug')('validator')

helper = require './helper'

# Check if value is valid
# -------------------------------------------------
# This will check the given value against the checks defined in the options.
# It will only give a value of true or false to the callback.
exports.is = (source, options, value, cb) ->
  not exports.check source, options, value, (err) ->
    cb not err?
    not err?

# Check value and sanitize
# -------------------------------------------------
# This will check the given value, sanitize it and return the new value or an
# Error to the callback.
exports.check = (source, options, value, data = {}, cb) ->
  if not cb? and typeof data is 'function'
    cb = data
    data = {}
  debug "Validating #{source}..."
# data for first run
  work =
    refrun: false
  unless cb?
    # first run
    value = helper.check source, options, value, work
    return value if value instanceof Error or not work.refrun
    # second run if needed
    work.self = value
    work.data = data
    return helper.reference source, options, value, work
  #firstrun
  helper.check source, options, value, work, (err, value) ->
    return cb err, value if err or not work.refrun
    # secondrun if needed
    work.self = value
    work.data = data
    helper.reference source, options, value, work, cb

# Check if value is valid
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (options = {}) ->
  helper.describe options
