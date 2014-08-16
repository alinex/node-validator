# Boolean value validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:type')
async = require 'async'
util = require 'util'
# include classes and helper
helper = require '../helper'
reference = require '../reference'

# Sanitize and validate
# -------------------------------------------------
exports.check = (source, options, value, work, cb) ->
  if typeof value is 'string'
    debug "Check #{value} for #{source}"
  else
    debug "Check #{value} for #{source}"
  unless value?
    return helper.result null, source, options, false, cb
  switch typeof value
    when 'boolean'
      return helper.result null, source, options, value, cb
    when 'string'
      switch value.toLowerCase()
        when 'true', '1', 'on', 'yes'
          return helper.result null, source, options, true, cb
        when 'false', '0', 'off', 'no'
          return helper.result null, source, options, false, cb
    when 'number'
      switch value
        when 1
          return helper.result null, source, options, true, cb
        when 0
          return helper.result null, source, options, false, cb
    else
      return helper.result "No boolean value given", source, options, null, cb
  helper.result "The value #{value} is no boolean", source, options, null, cb

# Reference check
# -------------------------------------------------
exports.reference = (source, options, value, work, cb) ->
  # call reference check
  unless options.reference?
    # no sub element possible, so returning
    return helper.result null, source, options, value, cb
  # check references
  unless cb?
    value = reference.check source, options.reference, value, work
    if value instanceof Error
      return helper.result value, source, options, null
    return helper.result null, source, options, value
  reference.check source, options.reference, value, work, (err, value) ->
    return helper.result err, source, options, value, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  text = "The value has to be a boolean. The value will be true for 1, 'true', 'on',
  'yes' and it will be considered as false for 0, 'false', 'off', 'no', '.
  Other values are not allowed."
  if options.reference
    text += "\n" + reference.describe options.reference
  text

