# Float validator
# =================================================

# Node modules
# -------------------------------------------------
async = require 'async'
util = require 'util'
# include classes and helper
helper = require '../helper'
reference = require '../reference'


# Sanitize and validate
# -------------------------------------------------
#
# Sanitize options allowed:
#
# - `sanitize` - (bool) remove invalid characters
# - `round` - (int) number of decimal digits to round to
#
# Check options:
#
# - `optional` - the value must not be present (will return null)
# - `min` - (numeric) the smalles allowed number
# - `max` - (numeric) the biggest allowed number
exports.check = (source, options, value, work, cb) ->
  # check optional
  result = helper.optional source, options, value, cb
  return result unless result is false
  # sanitize
  if typeof value is 'string'
    if options.sanitize
      value = value.replace /^.*?(-?\d+\.?\d*).*?$/, '$1'
    if value.length
      value = Number value
  if options.round?
    exp = Math.pow 10, options.round
    value = Math.round(value * exp) / exp
  # validate
  unless not isNaN(parseFloat value) and isFinite value
    return helper.result "The given value '#{value}' is no number as needed
     ", source, options, null, cb
  if options.min? and value < options.min
    return helper.result "The value is to low, it has to be at least
      '#{options.min}'", source, options, null, cb
  if options.max? and value > options.max
    return helper.result "The value is to high, it has to be'#{options.max}'
      or lower", source, options, null, cb
  # done return resulting value
  return helper.result null, source, options, value, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  text = 'A numeric value (float) is needed. '
  if options.sanitize
    text += "Invalid characters will be removed from text. "
  if options.round?
    text += "Value will be rounded arithmetic to #{options.round} digits. "
  if options.min? and options.max?
    text += "The value should be between #{options.min} and #{options.max}. "
  else if options.min?
    text += "The value should be greater than #{options.min}. "
  else if options.max?
    text += "The value should be lower than #{options.max}. "
  if options.optional
    text += "The setting is optional. "
  text += "\n" + reference.describe options.reference if options.reference
  text.trim()

