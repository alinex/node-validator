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
math = require 'mathjs'
# alinex modules
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'
check = require '../helper/check'


# Setup Math.js
# -------------------------------------------------
# Additional derived units are added:
math.type.Unit.BASE_UNITS.FREQUENCY = {}
math.type.Unit.UNITS.hz =
  name: 'Hz',
  base: math.type.Unit.BASE_UNITS.FREQUENCY,
  prefixes: math.type.Unit.PREFIXES.SHORT
  value: 1, offset: 0


# Exported Methods
# -------------------------------------------------

# Type specific debug method.
exports.debug = debug

# Initialize schema.
exports.init = ->
  @schema.round = true if @schema.decimals and not @schema.round?
  @schema.decimals = 0 if @schema.round and not @schema.decimals?


# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  # combine into message
  text = "A numeric floating point number. "
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if @schema.sanitize
    text += "Invalid characters will be removed from text. "
  # round
  if @schema.round
    type = switch @schema.round
      when 'ceil' then 'to ceil'
      when 'floor' then 'to floor'
      else 'arithḿeticaly'
    text += "The value will be rounded #{type} to #{@schema.decimals} decimals. "
  # minmax
  if @schema.min? and @schema.max?
    text += "The value should be between #{@schema.min} and #{@schema.max}. "
  else if @schema.min?
    text += "The value should be greater than #{@schema.min}. "
  else if @schema.max?
    text += "The value should be lower than #{@schema.max}. "
  if @schema.toUnit
    text += "The number will be formated in #{@schema.toUnit}. "
  if @schema.format
    text += "The number will be formatted like #{@schema.format}. "
  cb null, text



# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  rules.optional.check.call this, (err, skip) =>
    return cb err if err
    return cb() if skip
    # convert units
    if @schema.unit?
      if typeof @value is 'number' or (typeof @value is 'string' and @value.match /\d$/)
        @value = "" + @value + @schema.unit
        @value = math.unit @value
        @value = @value.toNumber @schema.unit
    # sanitize string
    if @schema.sanitize and typeof @value is 'string'
      @value = @value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
      @value = Number @value if @value.length
    # round
    if @schema.round
      exp = Math.pow 10, @schema.decimals
      @value = @value * exp
      @value = switch @schema.round
        when 'ceil' then Math.ceil @value
        when 'floor' then Math.floor @value
        else Math.round @value
      @value = @value / exp
    # is number
    unless not isNaN(parseFloat @value) and isFinite @value
      return @sendError "The given value is no number as needed", cb
    # minmax
    if @schema.min? and @value < @schema.min
      return @sendError "The value is to low, it has to be at least #{@schema.min}", cb
    if @schema.max? and @value > @schema.max
      return @sendError "The value is to high, it has to be at #{@schema.max} or lower", cb
    # output format
    if @schema.toUnit
      @value = math.unit @value, @schema.unit ? @schema.toUnit
      @value = @value.to 'min' if @value.units[0].unit.name is 's' and @value.toNumber('s') > 120
      @value = @value.to 'h' if @value.units[0].unit.name is 'min' and @value.toNumber('min') > 120
      @value = @value.to 'day' if @value.units[0].unit.name is 'h' and @value.toNumber('h') > 48
      if @schema.format
        numeral = require 'numeral'
        if @schema.locale
          try
            numeral.language @schema.locale, require "numeral/languages/#{@schema.locale}"
            numeral.language @schema.locale
        [v, p] = @value.format().split /[ ]/
        @value = numeral(v).format(@schema.format) + ' ' + p
        if @schema.locale
          numeral.language 'en'
      else
        @value = @value.format()
    else if @schema.format
      numeral = require 'numeral'
      if @schema.locale
        try
          numeral.language @schema.locale, require "numeral/languages/#{@schema.locale}"
          numeral.language @schema.locale
      @value = numeral(@value).format @schema.format
      if @schema.locale
        numeral.language 'en'
    # done checking and sanuitizing
    @sendSuccess cb




exports.selfcheck = (schema, cb) ->
  console.log 'ssssssssssssss'
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
