# Date interval check
# =================================================

# Sanitize options allowed:
#
# - `unit` - (string) type of unit to convert if not integer given
# - `round` - (bool) rounding can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
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
{number} = require 'alinex-util'
# include classes and helper
rules = require '../rules'
float = require './float'

module.exports = interval =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      options = optimize options
      # combine into message
      text = 'A time interval. '
      text += "If defined as a text it may use a combination of values with the
        units: ms, s, m, h, d. "
      text = text.replace /\. If/, ' which if'
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
      debug "#{check.pathname path} check: #{util.inspect(value).replace /\n/g, ''}"
      , chalk.grey util.inspect options
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
          type: 'float'
          optional: true
        unit:
          type: 'string'
          optional: true
          values: ['d', 'h', 'm', 's', 'ms']
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
            type: 'float'
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
