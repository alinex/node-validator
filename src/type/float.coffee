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
util = require 'util'
chalk = require 'chalk'
math = require 'mathjs'
# include classes and helper
rules = require '../rules'

# Extend Math.js
# -------------------------------------------------
# Additional derived units are added:

math.type.Unit.BASE_UNITS.FREQUENCY = {}
math.type.Unit.UNITS.hz =
  name: 'Hz',
  base: math.type.Unit.BASE_UNITS.FREQUENCY,
  prefixes: math.type.Unit.PREFIXES.SHORT
  value: 1, offset: 0


module.exports = float =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      options = optimize options
      # combine into message
      text = "A numeric floating point number. "
      text += rules.describe.optional options
      text = text.replace /\. It's/, ' which is'
      if options.sanitize
        text += "Invalid characters will be removed from text. "
      text += float.describe.round options
      text += float.describe.minmax options

    round: (options) ->
      if options.round
        type = switch options.round
          when 'to ceil' then Math.ceil value
          when 'to floor' then Math.floor value
          else 'arithḿeticaly'
        return "The value will be rounded #{type} to #{options.decimals} decimals. "
      ''

    minmax: (options) ->
      if options.min? and options.max?
        return "The value should be between #{options.min} and #{options.max}. "
      else if options.min?
        return "The value should be greater than #{options.min}. "
      else if options.max?
        return "The value should be lower than #{options.max}. "
      ''

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
      # convert units
      if options.unit?
        if typeof value is 'number' or (typeof value is 'string' and value.match /\d$/)
          value = "" + value + options.unit
        value = math.unit value
        value = value.toNumber options.unit
      # sanitize string
      if typeof value is 'string'
        if options.sanitize
          value = value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
        if value.length
          value = Number value
      value = float.sync.round check, path, options, value
      # validate
      value = float.sync.number check, path, options, value
      value = float.sync.minmax check, path, options, value
      # done return resulting value
      value

    number: (check, path, options, value) ->
      unless not isNaN(parseFloat value) and isFinite value
        throw check.error path, options, value,
        new Error "The given value #{util.inspect value} is no number as needed"
      value

    round: (check, path, options, value) ->
      if options.round
        exp = Math.pow 10, options.decimals
        value = value * exp
        value = switch options.round
          when 'ceil' then Math.ceil value
          when 'floor' then Math.floor value
          else Math.round value
        value = value / exp
      value

    minmax: (check, path, options, value) ->
      if options.min? and value < options.min
        throw check.error path, options, value,
        new Error "The value is to low, it has to be at least #{options.min}"
      if options.max? and value > options.max
        throw check.error path, options, value,
        new Error "The value is to high, it has to be'#{options.max}' or lower"
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
        sanitize:
          type: 'boolean'
          optional: true
        unit:
          type: 'string'
          optional: true
          minLength: 1
        round:
          type: 'integer'
          optional: true
          min: 0
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
