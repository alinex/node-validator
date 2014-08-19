# Percent check
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
  if typeof value is 'string' and value.trim().slice(-1) is '%'
    value = value[0..-2]
    unless not isNaN(parseFloat value) and isFinite value
      return helper.result "The given value '#{value}' is no number as needed
       ", source, options, null, cb
    value = value / 100
  # validate float value
  value = float.check source,
    type: 'float'
    title: options.title
    description: options.description
    min: options.min
    max: options.max
    round: options.round
  , value
  if value instanceof Error
    return helper.result value, source, options, null, cb
  # done return resulting value
  return helper.result null, source, options, value, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  text = 'This should be a percentage value which may be given as decimal 0..1
  or as percent value like 30%. '
  if options.round?
    text += "Value will be rounded arithmetic to #{options.round} digits. "
  if options.min? and options.max?
    text += "The value should be between #{options.min*100}% and #{options.max*100}%. "
  else if options.min?
    text += "The value should be greater than #{options.min*100}%. "
  else if options.max?
    text += "The value should be lower than #{options.max*100}%. "
  text.trim()
