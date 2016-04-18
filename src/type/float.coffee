# Float validator
# =================================================

# Sanitize options allowed:
#
# - `sanitize` - (bool) remove invalid characters
# - `unit` - (string) unit to convert to if no number is given
# - `round` - (bool) rounding of float can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
# - `decimals` - (int) number of decimal digits to round to
#
# Check options:
#
# - `min` - (numeric) the smallest allowed number
# - `max` - (numeric) the biggest allowed number


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:float')
chalk = require 'chalk'
math = require 'mathjs'
# alinex modules
util = require 'alinex-util'
# include classes and helper
check = require '../check'

# Extend Math.js
# -------------------------------------------------
# Additional derived units are added:
math.type.Unit.BASE_UNITS.FREQUENCY = {}
math.type.Unit.UNITS.hz =
  name: 'Hz',
  base: math.type.Unit.BASE_UNITS.FREQUENCY,
  prefixes: math.type.Unit.PREFIXES.SHORT
  value: 1, offset: 0

# Helper methods
# -------------------------------------------------
optimize = (work) ->
  work.pos.round = true if work.pos.decimals and not work.pos.round?
  work.pos.decimals = 0 if work.pos.round and not work.pos.decimals?

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  optimize work
  # combine into message
  text = "A numeric floating point number. "
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if work.pos.sanitize
    text += "Invalid characters will be removed from text. "
  # round
  if work.pos.round
    type = switch work.pos.round
      when 'ceil' then 'to ceil'
      when 'floor' then 'to floor'
      else 'arithḿeticaly'
    text += "The value will be rounded #{type} to #{work.pos.decimals} decimals. "
  # minmax
  if work.pos.min? and work.pos.max?
    text += "The value should be between #{work.pos.min} and #{work.pos.max}. "
  else if work.pos.min?
    text += "The value should be greater than #{work.pos.min}. "
  else if work.pos.max?
    text += "The value should be lower than #{work.pos.max}. "
  if work.pos.toUnit
    text += "The number will be formated in #{work.pos.toUnit}. "
  if work.pos.format
    text += "The number will be formatted like #{work.pos.format}. "
  cb null, text

exports.run = (work, cb) ->
  optimize work
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect value ? null}"
      return cb()
  catch error
    return work.report error, cb
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
      value = value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
    if value.length
      value = Number value
  # round
  if work.pos.round
    exp = Math.pow 10, work.pos.decimals
    value = value * exp
    value = switch work.pos.round
      when 'ceil' then Math.ceil value
      when 'floor' then Math.floor value
      else Math.round value
    value = value / exp
  # is number
  unless not isNaN(parseFloat value) and isFinite value
    return work.report (new Error "The given value #{util.inspect value} is no
      number as needed"), cb
  # minmax
  if work.pos.min? and value < work.pos.min
    return work.report (new Error "The value is to low, it has to be at least
      #{work.pos.min}"), cb
  if work.pos.max? and value > work.pos.max
    return work.report (new Error "The value is to high, it has to be'#{work.pos.max}'
      or lower"), cb
  # output format
  if work.pos.toUnit
    value = math.unit value, work.pos.unit ? work.pos.toUnit
    value = value.to 'min' if value.units[0].unit.name is 's' and value.toNumber('s') > 120
    value = value.to 'h' if value.units[0].unit.name is 'min' and value.toNumber('min') > 120
    value = value.to 'day' if value.units[0].unit.name is 'h' and value.toNumber('h') > 48
    if work.pos.format
      numeral = require 'numeral'
      if work.pos.locale
        try
          numeral.language work.pos.locale, require "numeral/languages/#{work.pos.locale}"
          numeral.language work.pos.locale
      [v, p] = value.format().split /[ ]/
      value = numeral(v).format(work.pos.format) + ' ' + p
      if work.pos.locale
        numeral.language 'en'
    else
      value = value.format()
  else if work.pos.format
    numeral = require 'numeral'
    if work.pos.locale
      try
        numeral.language work.pos.locale, require "numeral/languages/#{work.pos.locale}"
        numeral.language work.pos.locale
    value = numeral(value).format work.pos.format
    if work.pos.locale
      numeral.language 'en'
  # done return resulting value
  debug "#{work.debug} result #{util.inspect value ? null}"
  cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: util.extend util.clone(check.base),
        default:
          type: 'float'
          optional: true
        sanitize:
          type: 'boolean'
          optional: true
        unit:
          type: 'string'
          optional: true
          minLength: 1
        round:
          type: 'or'
          optional: true
          or: [
            type: 'boolean'
          ,
            type: 'string'
            values: ['floor', 'ceil']
          ]
        decimals:
          type: 'integer'
          optional: true
          min: 0
        min:
          type: 'float'
          optional: true
        max:
          type: 'float'
          optional: true
          min: '<<<min>>>'
        toUnit:
          type: 'string'
          optional: true
        format:
          type: 'string'
          optional: true
        locale:
          type: 'string'
          match: /^[a-z]{2}(-[A-Z]{2})?$/
          optional: true
    value: schema
  , cb
