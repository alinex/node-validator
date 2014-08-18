# Date interval check
# =================================================

# Node modules
# -------------------------------------------------
async = require 'async'
util = require 'util'
# include alinex packages
{number} = require 'alinex-util'
# include classes and helper
helper = require '../helper'
float = require './float'
reference = require '../reference'

# Sanitize and validate
# -------------------------------------------------
#
# Sanitize options allowed:
#
# - `unit` - (string) type of unit to convert if not integer given
# - `round` - (bool) rounding of float can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
#
# Check options:
#
# - `min` - (integer) the smalles allowed number
# - `max` - (integer) the biggest allowed number
exports.check = (source, options, value, work, cb) ->
  # sanitize
  if typeof value is 'string'
    parsed = number.parseMSeconds value
    if isNaN parsed
      return helper.result "The given value '#{value}' is not parse able as
        interval", source, options, null, cb
    unit = options.unit ? 'ms'
    unless unit is 'ms'
      parsed /= switch unit
        when 's'
          1000
        when 'm'
          1000 * 60
        when 'h'
          1000 * 60 * 60
        when 'd'
          1000 * 60 * 60 * 24
    value = parsed
  if options.round
    value = switch options.round
      when 'ceil' then Math.ceil value
      when 'floor' then Math.floor value
      else Math.round value
  if typeof value isnt 'number'
    return helper.result "A number should be given", source, options, null, cb
  # validate integer value
  value = float.check source,
    type: 'float'
    title: options.title
    description: options.description
    min: options.min
    max: options.max
  , value
  if value instanceof Error
    return helper.result value, source, options, null, cb
  # done return resulting value
  return helper.result null, source, options, value, cb

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
  text = 'An time interval is needed, here. '
  text += "If defined as a text you may use a combination of values with the
    units: ms, s, m, h, d. "
  if options.unit
    text += "The result will be given as the number of #{options.unit}. "
  if options.round
    type = switch options.round
      when 'to ceil' then Math.ceil value
      when 'to floor' then Math.floor value
      else 'arithḿetic'
    text += "Value will be rounded #{type}. "
  if options.min? and options.max?
    text += "The value should be between #{options.min} and #{options.max}. "
  else if options.min?
    text += "The value should be greater than #{options.min}. "
  else if options.max?
    text += "The value should be lower than #{options.max}. "
  text.trim()
