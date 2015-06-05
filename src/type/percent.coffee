# Percent check
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
debug = require('debug')('validator:percent')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# Optimize options setting
# -------------------------------------------------
optimize = (schema) ->
  if schema.decimals and not schema.round?
    schema.round = true
  if schema.round and not schema.decimals?
    schema.decimals = 2
  schema

subcheck =
  type: 'or'
  or: [
    type: 'float'
  ,
    type: 'string'
    match: ///
      ^\s*      # start with possible spaces
      [+-]?     # sign possible
      \s*\d+(\.\d*)? # float number
      \s*%?     # percent sign with spaces
      \s*$      # end of text with spaces
      ///
  ]

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  work.pos = optimize work.pos
  # combine into message
  text = 'A percentage value as decimal like 0.3 but it may be given
  as percent value text like 30%, too. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
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
    # get float from string
    if typeof value is 'string' and value.trim().slice(-1) is '%'
      value = value[0..-2]
      unless not isNaN(parseFloat value) and isFinite value
        return work.report (new Error "The given value '#{value}' is no number as needed"), cb
      value = value / 100
    else
      value = parseFloat value
    # validate number
    console.log work.pos
    check.run
      name: name
      value: value
      schema:
        type: 'float'
        round: work.pos.round
        decimals: work.pos.decimals
        min: work.pos.min
        max: work.pos.max
    , cb

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'float'
          optional: true
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
