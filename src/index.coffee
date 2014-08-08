# Validator
# =================================================

debug = require('debug')('validator')

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
  getType(options.check).check source, value, options, cb

# Check if value is valid
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (options) ->
  getType(options.check).describe options

# Create a descriptive error message
# -------------------------------------------------
# This is used internally only.
# This will contain the title and description from the configuration if there.
exports.error = (err, source = "unknown", options, value) ->
  if err
    unless err instanceof Error
      text = "#{err} in #{source}"
      text += " for \"#{options.title}\"" if options.title?
      text += "."
      text += "\nIt should contain #{options.description}." if options.description?
      err = new Error text
    debug "Failed: #{err.message}"
  else
    debug "Succeeded with '#{value}' in #{source}"
  err

# Send value or error
# -------------------------------------------------
# This is used internally only.
# This helps supporting both return values and callbacks at the same time.
# This will contain the title and description from the configuration if there.
exports.result = (err, source, options, value, cb = ->) ->
  err = exports.error err, source, options, value
  cb err, value
  err ? value
