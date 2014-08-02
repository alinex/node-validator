# Validator
# =================================================

# Get the type functions
# -------------------------------------------------
# This small helper will load the package and return the specific type hash.
getType = (name) ->
  [group, type] = name.split /\./
  mod = require "./#{group}"
  mod[type]

# Check if value is valid
# -------------------------------------------------
# This will check the given value against the checks defined in the options.
# It will only give a value of true or false to the callback.
exports.is = (name, value, options, cb) ->
  not exports.check name, value, options.options, (err) ->
    cb not err?
    not err?

# Check value and sanitize
# -------------------------------------------------
# This will check the given value, sanitize it and return the new value or an
# Error to the callback.
exports.check = (name, value, options, cb) ->
  getType(options.check).check name, value, options.options, cb

# Check if value is valid
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (options) ->
  getType(options.check).describe options.options

