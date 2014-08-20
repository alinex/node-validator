# Validator
# =================================================

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


# Check if value is valid
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (options) ->
  ValidatorCheck.describe options
