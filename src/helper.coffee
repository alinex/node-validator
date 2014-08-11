# Validator Helper methods
# =================================================

debug = require('debug')('validator')

# Get the type functions
# -------------------------------------------------
# This small helper will load the package and return the specific type hash.
exports.getType = (name) ->
  [group, type] = name.split /\./
  mod = require "./#{group}"
  mod[type]

# Check for empty value
# -------------------------------------------------
exports.isEmpty = (value) ->
  return true unless value?
  switch typeof value
    when 'object'
      if value.constructor.name is 'Object' and Object.keys(value).length is 0
        return true
    when 'array'
      if value.length is 0
        return true
  false

# Check for optional value
# -------------------------------------------------
# If called you have to check the return value to not be `false` then processing
# should be returned with the given value.
exports.optional = (source, options, value, cb) ->
  if exports.isEmpty value
    value = options.default ? null
    return exports.result null, source, options, value, cb if options.optional
    return exports.result "A value is needed", source, options, null, cb
  return false

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
