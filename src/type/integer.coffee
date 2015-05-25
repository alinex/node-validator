# Integer validator
# =================================================

# Sanitize options allowed:
#
# - `sanitize` - (bool) remove invalid characters
# - `unit` - (string) unit to convert to if no number is given
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

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:integer')
util = require 'util'
chalk = require 'chalk'
math = require 'mathjs'
# include classes and helper
check = require '../check'
float = require './float'

# integer type names
# -------------------------------------------------
integerTypes =
  byte: 8
  short: 16
  long : 32
  safe: 53
  quad: 64

# Type implementation
# -------------------------------------------------
exports.describe = (work) ->
  # combine into message
  text = "An integer value. "
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if work.pos.sanitize
    text += "Invalid characters will be removed from text. "
  # round
  if work.pos.round
    type = switch work.pos.round
      when 'ceil' then 'to ceil'
      when 'floor' then 'to floor'
      else 'arithḿetic'
    text += "The value will be rounded #{type} to an integer. "
  # integer type
  max = min = null
  if work.pos.inttype?
    type = integerTypes[work.pos.inttype] ? work.pos.inttype
    unit = if integerTypes[work.pos.inttype] then '' else 'byte'
    unsigned = if work.pos.unsigned then 'an unsigned' else 'a signed'
    text += "Only values in the range of #{unsigned} #{work.pos.inttype}#{unit}-integer
      are allowed. "
    unsigned = if work.pos.unsigned then 1 else 0
    max = (Math.pow 2, type-1+unsigned)-1
    min = (unsigned-1) * max - 1 + unsigned
  # minmax
  min = work.pos.min if work.pos.min? and (not min? or work.pos.min>min)
  max = work.pos.max if work.pos.max? and (not max? or work.pos.max<max)
  if min? and max?
    text += "The value should be between #{min} and #{max}. "
  else if min?
    text += "The value should be greater than #{min}. "
  else if max?
    text += "The value should be lower than #{max}. "
  text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return cb work.report err
  value = work.value
  # convert units
  if work.pos.unit?
    if typeof value is 'number' or (typeof value is 'string' and value.match /\d$/)
      value = "" + value + work.pos.unit
    value = math.unit value
    value = value.toNumber work.pos.unit
  # sanitize string
  if typeof value is 'string'
    if work.pos.sanitize
      if work.pos.round?
        value = value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
      else
        value = value.replace /^.*?([-+]?\d+).*?$/, '$1'
    if value.length
      value = Number value
  # round
  if work.pos.round
    value = switch work.pos.round
      when 'ceil' then Math.ceil value
      when 'floor' then Math.floor value
      else Math.round value
  # check integer
  unless value is (value | 0)
    return cb work.report new Error "The given value '#{value}' is no integer as needed"
  # integer type
  if work.pos.inttype
    type = integerTypes[work.pos.inttype] ? work.pos.inttype
    unit = if integerTypes[work.pos.inttype] then '' else 'byte'
    unsigned = if work.pos.unsigned then 1 else 0
    max = (Math.pow 2, type-1+unsigned)-1
    min = (unsigned-1) * max - 1 + unsigned
    if value < min or value > max
      return cb work.report new Error "The value is out of range for
      #{work.pos.inttype}#{unit}-integer"
  # minmax
  if work.pos.min? and value < work.pos.min
    return cb work.report new Error "The value is to low, it has to be at least #{work.pos.min}"
  if work.pos.max? and value > work.pos.max
    return cb work.report new Error "The value is to high, it has to be'#{work.pos.max}' or lower"
  # done return resulting value
  cb null, value

exports.selfcheck =
type: 'object'
allowedKeys: true
entries:
  type:
    type: 'string'
  title:
    type: 'string'
    optional: true
  description:
    type: 'string'
    optional: true
  optional:
    type: 'boolean'
    optional: true
  default:
    type: 'integer'
    optional: true
  sanitize:
    type: 'boolean'
    optional: true
  unit:
    type: 'string'
    optional: true
    minLength: 1
  round:
    type: 'any'
    optional: true
    entries: [
      type: 'boolean'
    ,
      type: 'string'
      values: ['floor', 'ceil']
    ]
  min:
    type: 'any'
    optional: true
    entries: [
      type: 'integer'
    ,
#      rules.selfcheck.reference
    ]
  max:
    type: 'any'
    optional: true
    min:
      reference: 'relative'
      source: '<min'
    entries: [
      type: 'integer'
    ,
#      rules.selfcheck.reference
    ]
  inttype:
    type: 'any'
    optional: true
    entries: [
      type: 'integer'
    ,
      type: 'string'
      values: ['byte', 'short','long','quad', 'safe']
    ]
  unsigned:
    type: 'boolean'
    optional: true
