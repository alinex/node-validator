# Integer validator
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
# - `round` - (bool) rounding of float can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
#
# Check options:
#
# - `min` - (integer) the smalles allowed number
# - `max` - (integer) the biggest allowed number
# - `inttype` - (integer|string) the integer is of given type
#   (4, 8, 16, 32, 64, 'byte', 'short','long','quad', 'safe')
# - `unsigned` - (bool) the integer has to be positive

integerTypes =
  byte: 8
  short: 16
  long : 32
  safe: 53
  quad: 64

exports.check = (source, options, value, work, cb) ->
  # sanitize
  if typeof value is 'string'
    if options.sanitize
      if options.round?
        value = value.replace /^.*?(-?\d+\.?\d*).*?$/, '$1'
      else
        value = value.replace /^.*?(-?\d+).*?$/, '$1'
    if value.length
      value = Number value
  if options.round
    value = switch options.round
      when 'ceil' then Math.ceil value
      when 'floor' then Math.floor value
      else Math.round value
  # validate
  unless value is (value | 0)
    return helper.result "The given value '#{value}' is no integer as needed
     ", source, options, null, cb
  if options.min? and value < options.min
    return helper.result "The value is to low, it has to be at least
      #{options.min}", source, options, null, cb
  if options.max? and value > options.max
    return helper.result "The value is to high, it has to be #{options.max}
      or lower", source, options, null, cb
  if options.inttype
    type = integerTypes[options.inttype] ? options.inttype
    unit = integerTypes[options.inttype] ? 'byte'
    unsigned = if options.unsigned then 1 else 0
    max = (Math.pow 2, type-1+unsigned)-1
    min = (unsigned-1) * max - 1 + unsigned
    if value < min or value > max
      return helper.result "The value is out of range for #{options.inttype}
        #{unit}-integer", source, options, null, cb
  # done return resulting value
  return helper.result null, source, options, value, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  text = 'An integer value is needed, here. '
  if options.sanitize
    text += "Invalid characters will be removed from text. "
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
  if options.inttype?
    type = integerTypes[options.inttype] ? options.inttype
    unit = integerTypes[options.inttype] ? 'byte'
    unsigned = if options.unsigned then 'unsigned' else 'signed'
    text += "Only values in the range of a #{unsigned} #{type}#{unit}-integer
      are allowed. "
  text.trim()

