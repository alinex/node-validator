# Date interval check
# =================================================

# Sanitize options allowed:
#
# - `unit` - (string) type of unit to convert if not integer given
# - `round` - (bool) rounding can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
# - `decimals` - (int) number of decimal digits to round to (defaults to 2)
#
# Check options:
#
# - `min` - (integer) the smalles allowed number
# - `max` - (integer) the biggest allowed number

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:interval')
util = require 'util'
chalk = require 'chalk'
# include alinex packages
# alinex modules
{object,number} = require 'alinex-util'
# include classes and helper
check = require '../check'

# Optimize options setting
# -------------------------------------------------
optimize = (schema) ->
  if schema.decimals and not schema.round?
    schema.round = true
  if schema.round and not schema.decimals?
    schema.decimals = 0
  schema

subcheck =
  type: 'or'
  or: [
    type: 'float'
  ,
    type: 'string'
    match: /^\d\d?:\d\d?(:\d\d?)?(\.\d+)?$/
  ,
    type: 'string'
    match: /^([+-]?\d+(?:\.\d+)?)\s*([smhd]|ms)$/
  ]

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  work.pos = optimize work.pos
  # combine into message
  text = "A time interval as float, in time format or as text which may use a
  combination of values with the units: ms, s, m, h, d. "
  text += check.optional.describe work
  if work.pos.unit
    text += "The result will be given as the number of #{work.pos.unit}. "
  # subcheck
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.describe
    name: name
    schema:
      type: 'float'
      round: work.pos.round
      decimals: work.pos.decimals
      min: work.pos.min
      max: work.pos.max
  , (err, subtext) ->
    return cb err if err
    cb null, text + subtext

exports.run = (work, cb) ->
  work.pos = optimize work.pos
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  # first check input type
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.run
    name: name
    value: work.value
    schema: subcheck
  , (err, value) ->
    return cb err if err
    # support time format
    if typeof value is 'string'
      if value.trim().match /^(\d\d?)(:\d\d?)(:\d\d?)?(\.\d+)?$/
        parts = value.split ':'
        value = "#{parts[0]}h #{parts[1]}m"
        value += " #{parts[2]}s" if parts.length is 3
      parsed = number.parseMSeconds value
      if isNaN parsed
        return work.report (new Error "The given value '#{value}' is not parse
          able as interval"), cb
      unit = work.pos.unit ? 'ms'
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
    # run float check
    check.run
      name: name
      value: value
      schema:
        type: 'float'
        round: work.pos.round
        decimals: work.pos.decimals
        min: work.pos.min
        max: work.pos.max
    , (err, value) ->
      return err if err
      debug "#{work.debug} result #{util.inspect value}"
      cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'float'
          optional: true
        unit:
          type: 'string'
          optional: true
          values: ['d', 'h', 'm', 's', 'ms']
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
#          min: '<<<min>>>'
    value: schema
  , cb
