# Validator Helper methods
# =================================================

debug = require('debug')('validator:type')
util = require 'util'
# internal classes and helper
reference = require './reference'

# Check value and sanitize
# -------------------------------------------------
# this may also be used for subcalls.
exports.check = (source, options = {}, value, work, cb) ->
  lib = require "./type/#{options.type}"
  work.refrun = true if options.reference?
  debug "check #{options.type} '#{value}' in #{source}", util.inspect(options).grey
  # check optional
  result = exports.optional source, options, value, cb
  return result unless result is false
  # normal check through type library
  lib.check source, options, value, work, cb

# Check value and sanitize
# -------------------------------------------------
# this may also be used for subcalls.
exports.reference = (source, options = {}, value, data, cb) ->
  lib = require "./type/#{options.type}"
  # run library check if defined else do the default check here
  if lib.reference?
    debug "#{options.type} reference in #{source}", util.inspect(options).grey
    return lib.reference source, options, value, work, cb
  # skip reference check if not defined
  unless options.reference
    return exports.result null, source, options, value, cb
  # check references sync
  unless cb?
    value = reference.check source, options.reference, value, work
    if value instanceof Error
      return exports.result value, source, options, null
    return exports.result null, source, options, value
  # check references async
  reference.check source, options.reference, value, work, (err, value) ->
    exports.result err, source, options, value, cb


# Check if value is valid
# -------------------------------------------------
# This will directly return the description of how the value has to be.
exports.describe = (options = {}) ->
  lib = require "./type/#{options.type}"
  text = lib.describe options
  if options.default
    text += " The setting is optional and will be set to '#{options.default}'."
  else if options.optional
    text += " The setting is optional."
  text += "\n" + reference.describe options.reference if options.reference
  text

# Check for optional value
# -------------------------------------------------
# If called you have to check the return value to not be `false` then processing
# should be returned with the given value.
exports.optional = (source, options, value, cb) ->
  # check optional
  if options.type isnt 'boolean' and exports.isEmpty value
    unless options.optional or options.default
      return exports.result "A value is needed", source, options, null, cb
    value = options.default ? null
    return exports.result null, source, options, value, cb if options.optional
  return false

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
    debug "Succeeded in #{source}", util.inspect(options).grey
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
