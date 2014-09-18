# Byte check
# =================================================

# Sanitize options allowed:
#
# - `round` - (bool) rounding can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
#
# Check options:
#
# - `min` - (integer) the smalles allowed number
# - `max` - (integer) the biggest allowed number

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:metric')
util = require 'util'
# include alinex packages
{number} = require 'alinex-util'
# include classes and helper
rules = require '../rules'
float = require './float'

# 10^x
prefix =
  Y: 24
  Z: 21
  E: 18
  P: 15
  T: 12
  G: 9
  M: 6
  k: 3
  h: 2
  da: 1
  d: -1
  c: -2
  m: -3
  µ: -6
  n: -9
  p: -12
  f: -15
  a: -18
  z: -21
  y: -24

# (2^10)^x
prefixSI:
  Yi: 8
  Zi: 7
  Ei: 6
  Pi: 5
  Ti: 4
  Gi: 3
  Mi: 2
  Ki: 1

module.exports = metric =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      options = optimize options
      # combine into message
      text = 'A byte size is needed, here. '
      text += "If defined as a text you may use a prefix of:
        units: ms, s, m, h, d. "
      text += rules.describe.optional options
      if options.unit
        text += "The result will be given as the number of #{options.unit}. "
      text += float.describe.round options
      text += float.describe.minmax options

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}", util.inspect(options).grey
      options = optimize options
      # sanitize
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # support time format
      if typeof value is 'string'
        if value.trim().match /^(\d\d?)(:\d\d?)(:\d\d?)?(\.\d+)?$/
          parts = value.split ':'
          value = "#{parts[0]}h #{parts[1]}m"
          value += " #{parts[2]}s" if parts.length is 3
        parsed = number.parseMSeconds value
        if isNaN parsed
          throw check.error path, options, value,
          new Error "The given value '#{value}' is not parse able as interval"
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
      value = float.sync.round check, path, options, value
      # validate
      value = float.sync.number check, path, options, value
      value = float.sync.minmax check, path, options, value
      # done return resulting value
      value


  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
      type: 'object'
      mandatoryKeys: ['type']
      allowedKeys: true
      entries:
        title:
          type: 'string'
        description:
          type: 'string'
        optional:
          type: 'boolean'
        default:
          type: 'float'
        unit:
          type: 'string'
          values: ['d', 'h', 'm', 's', 'ms']
        round:
          type: 'any'
          entries: [
            type: 'boolean'
          ,
            type: 'string'
            values: ['floor', 'ceil']
          ]
        min:
          type: 'any'
          entries: [
            type: 'float'
          ,
            rules.selfcheck.reference
          ]
        max:
          type: 'any'
          min:
            reference: 'relative'
            source: '<min'
          entries: [
            type: 'float'
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
  options
