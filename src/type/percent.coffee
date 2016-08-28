###
Percent
=================================================

Sanitize options allowed:
- `unit` - `String` unit to convert to if no number is given
- `round` - `Boolean|String` rounding of float can be set to true for arithmetic rounding
 or use `floor` or `ceil` for the corresponding methods
- `decimals` - `Integer` number of decimal digits to round to

Check options:
- `min` - `Numeric` the smallest allowed number
- `max` - `Numeric` the biggest allowed number


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node modules
# -------------------------------------------------
numeral = null # load on demand
# alinex modules
util = require 'alinex-util'
# include classes and helper
check = require '../check'

# Optimize options setting
# -------------------------------------------------
optimize = (schema) ->
  if schema.decimals? and not schema.round
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
    if work.pos.format
      text += "The number will be formatted like #{work.pos.format}. "
    # the float check will never throw an error, so go on
    cb null, text + subtext

exports.run = (work, cb) ->
  work.pos = optimize work.pos
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect work.value ? null}"
      return cb()
  catch error
    return work.report error, cb
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
      value = value[0..-2] / 100
    else
      value = parseFloat value
    # validate number
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
      return cb err if err
      if work.pos.format
        numeral ?= require 'numeral'
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
        format:
          type: 'string'
          optional: true
        locale:
          type: 'string'
          match: /^[a-z]{2}(-[A-Z]{2})?$/
          optional: true
    value: schema
  , cb
