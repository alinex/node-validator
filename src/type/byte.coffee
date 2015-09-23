# Date interval check
# =================================================

# Sanitize options allowed:
#
# - `unit` - (string) unit to convert to if no number is given
# - `round` - (bool) rounding can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
#
# Check options:
#
# - `min` - (integer) the smalles allowed number
# - `max` - (integer) the biggest allowed number
#
# This supports the units: B, Bytes, b, bps, bits

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:byte')
util = require 'util'
chalk = require 'chalk'
math = require 'mathjs'
# alinex modules
{object, number} = require 'alinex-util'
# include classes and helper
check = require '../check'

pattern = /^[0-9]+(\.?[0-9]*) *(k|Ki|[MGTPEZY]i?)?([Bb]|bps)?$/

# Extend Math.js
# -------------------------------------------------
# Additional derived binary units are added:
Unit = math.type.Unit
Unit.UNITS.bps =
  name: 'bps'
  base: Unit.BASE_UNITS.BIT
  dimensions: Unit.BASE_UNITS.BIT.dimensions
  prefixes: Unit.PREFIXES.BINARY_SHORT
  value: 1, offset: 0

# Optimize options setting
# -------------------------------------------------
optimize = (schema) ->
  if schema.decimals? and not schema.round
    schema.round = true
  if schema.round and not schema.decimals?
    schema.decimals = 2
  unless schema.min
    schema.min = 0
  schema

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  work.pos = optimize work.pos
  # combine into message
  text = 'A byte value. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  text += "If defined as a text you may use a prefix like: k, M, G, P, T, E, Z, Y
  also with the unit B like '12MB' or '3.7 GiB'. "
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
    # no error possible from float check, so go on
    cb null, text + subtext

exports.run = (work, cb) ->
  work.pos = optimize work.pos
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect value}"
      return cb()
  catch err
    return work.report err, cb
  value = work.value
  # support byte format
  if typeof value is 'string'
    unless value.trim().match pattern
      return work.report (new Error "A byte value with optional prefixes is needed"), cb
    # sanitize string
    value = value.trim()
    work.pos.unit ?= if value.match /(b|bits|bps)$/ then 'b' else 'B'
    unless value.match /([bB]|bps)$/
      value += work.pos.unit
    value = math.unit value
    value = value.toNumber work.pos.unit
  else if typeof value isnt 'number'
    unless value is (value | 0)
      return work.report (new Error "The given value '#{value}' is no byte or
        float number as needed"), cb
  # validate
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.run
    name: name
    value: value
    schema:
      type: if work.pos.unit?.match /^[kMGTPEZY]([bB]|bps)$/ then 'float' else 'integer'
      round: work.pos.round
      decimals: work.pos.decimals
      min: work.pos.min
      max: work.pos.max
  , (err, value) ->
    return cb err if err
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
          default: 'B'
          matches: /^[kMGTPEZY]?([bB]|bps)$/
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
    value: schema
  , cb
