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
# include alinex packages
{number} = require 'alinex-util'
# include classes and helper
rules = require '../rules'
float = require './float'

pattern = /^[0-9]+(\.?[0-9]*) *(k|Ki|[MGTPEZY]i?)?([Bb]|bps)?$/

# Extend Math.js
# -------------------------------------------------
# Additional derived binary units are added:
math.type.Unit.UNITS.bps =
  name: 'bps'
  base: math.type.Unit.BASE_UNITS.BIT
  prefixes: math.type.Unit.PREFIXES.BINARY_SHORT
  value: 1, offset: 0

module.exports = byte =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      options = optimize options
      # combine into message
      text = 'A byte value. '
      text += rules.describe.optional options
      text = text.replace /\. It's/, ' which is'
      text += "If defined as a text you may use a prefix like: k, M, G, P, T, E, Z, Y
      also with the unit B like '12MB' or '3.7 GiB'. "
      text += float.describe.minmax options

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "#{check.pathname path} check: #{util.inspect(value).replace /\n/g, ''}"
      , chalk.grey util.inspect options
      options = optimize options
      # sanitize
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # support byte format
      if typeof value is 'number'
        unless value is (value | 0)
          throw check.error path, options, value,
          new Error "The given value '#{value}' is no byte or integer number as needed"
        return float.sync.minmax check, path, options, value
      unless typeof value is 'string' and value.trim().match pattern
        throw check.error path, options, value,
        new Error "A byte value with optional prefixes is needed"
      # sanitize string
      value = value.trim()
      options.unit ?= if value.match /(b|bits|bps)$/ then 'b' else 'B'
      unless value.match /([bB]|bps)$/
        value += options.unit
      value = math.unit value
      value = value.toNumber options.unit
      # validate
      value = float.sync.minmax check, path, options, value
      # done return resulting value
      value


  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
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
        unit:
          type: 'string'
          default: 'B'
          matches: /^[kMGTPEZY]?([bB]|bps)$/
        min:
          type: 'any'
          optional: true
          entries: [
            type: 'integer'
            min: 0
          ,
            rules.selfcheck.reference
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
            rules.selfcheck.reference
          ]
    , options


# Optimize options setting
# -------------------------------------------------
optimize = (options) ->
  if options.decimals and not options.round?
    options.round = true
  if options.round and not options.decimals?
    options.decimals = 0
  unless options.min
    options.min = 0
  options
