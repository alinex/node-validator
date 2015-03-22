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
rules = require '../rules'
float = require './float'

module.exports = integer =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      # combine into message
      text = "An integer value. "
      text += rules.describe.optional options
      if options.sanitize
        text += "Invalid characters will be removed from text. "
      text += integer.describe.round options
      text += float.describe.minmax options
      if options.inttype?
        type = integerTypes[options.inttype] ? options.inttype
        unit = integerTypes[options.inttype] ? 'byte'
        unsigned = if options.unsigned then 'unsigned' else 'signed'
        text += "Only values in the range of a #{unsigned} #{type}#{unit}-integer
          are allowed. "
      text

    round: (options) ->
      if options.round
        type = switch options.round
          when 'to ceil' then Math.ceil value
          when 'to floor' then Math.floor value
          else 'arithḿetic'
        return "Value will be rounded #{type} to an integer. "
      ''


  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # sanitize
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # convert units
      if options.unit?
        if typeof value is 'number' or (typeof value is 'string' and value.match /\d$/)
          value = "" + value + options.unit
        value = math.unit value
        value = value.toNumber options.unit
      # sanitize string
      if typeof value is 'string'
        if options.sanitize
          if options.round?
            value = value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
          else
            value = value.replace /^.*?([-+]?\d+).*?$/, '$1'
        if value.length
          value = Number value
      value = integer.sync.round check, path, options, value
      # validate
      unless value is (value | 0)
        throw check.error path, options, value,
        new Error "The given value '#{value}' is no integer as needed"
      value = float.sync.minmax check, path, options, value
      if options.inttype
        type = integerTypes[options.inttype] ? options.inttype
        unit = integerTypes[options.inttype] ? 'byte'
        unsigned = if options.unsigned then 1 else 0
        max = (Math.pow 2, type-1+unsigned)-1
        min = (unsigned-1) * max - 1 + unsigned
        if value < min or value > max
          throw check.error path, options, value,
          new Error "The value is out of range for #{options.inttype} #{unit}-integer"
      # done return resulting value
      value

    round: (check, path, options, value) ->
      if options.round
        value = switch options.round
          when 'ceil' then Math.ceil value
          when 'floor' then Math.floor value
          else Math.round value
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
    , options


# integer type names
# -------------------------------------------------
integerTypes =
  byte: 8
  short: 16
  long : 32
  safe: 53
  quad: 64
