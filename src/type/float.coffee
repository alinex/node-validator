###
Float
=================================================
This will check a floating point number against a precise definition in which
range it may be.

Sanitize options allowed:
- `sanitize` - `Boolean` remove invalid characters
- `unit` - `String` unit to convert to if no number is given
- `round` - `Boolean|String` rounding of float can be set to true for arithmetic rounding
 or use `floor` or `ceil` for the corresponding methods
- `decimals` - `Integer` number of decimal digits to round to

Check options:
- `min` - `Numeric` the smallest allowed number
- `max` - `Numeric` the biggest allowed number

Format options:
- `toUnit` - `String` unit to convert value to
- `format` - `String` format number as string
- 'locale' - `String` locale format to use for string output

The result will be a `Number` or `String` representation of a number depending on
the above parameters.

#3 Additional Possibilities

Use the {@link or.coffee} type to allow multiple ranges.

#3 Alternative Number Checks

You may also use:
- {@link integer.coffee}
- {@link percent.coffee}
- {@link byte.coffee}


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
math = null # loaded on demand
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


# Setup
# -------------------------------------------------

# The math library will be loaded and additional derived units are added to
# it like: 'hz' as frequency type
initMath = ->
  return if math
  math = require 'mathjs'
  math.type.Unit.BASE_UNITS.FREQUENCY = {}
  math.type.Unit.UNITS.hz =
    name: 'Hz',
    base: math.type.Unit.BASE_UNITS.FREQUENCY,
    prefixes: math.type.Unit.PREFIXES.SHORT
    value: 1, offset: 0


# Exported Methods
# -------------------------------------------------

# Initialize schema.
exports.init = ->
  @schema.round = true if @schema.decimals and not @schema.round?
  @schema.decimals = 0 if @schema.round and not @schema.decimals?

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  # combine into message
  text = "A numeric floating point number. "
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if @schema.sanitize
    text += "Invalid characters will be removed from text. "
  # unit
  if @schema.unit
    text += "If no other unit given the number will be interpreted as #{@schema.unit}. "
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
  # output format
  if @schema.toUnit
    text += "The number will be formatted in unit '#{@schema.toUnit}'. "
  if @schema.format
    text = text.replace /\. $/, " and it will be written like '#{@schema.format}'. "
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # convert units
  if @schema.unit?
    initMath()
    if typeof @value is 'number' or (typeof @value is 'string' and @value.match /\d$/)
      @value = "" + @value + @schema.unit
    @value = math.unit @value
    @value = @value.toNumber @schema.unit
  # sanitize string
  if @schema.sanitize and typeof @value is 'string'
    @value = @value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
  if typeof @value is 'string' and @value.length
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
    initMath()
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

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Float"
  description: "a float schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'float'
      optional: true
    sanitize:
      title: "Sanitize"
      description: "a flag which allows removing of non numeric characters before evaluating"
      type: 'boolean'
      optional: true
    unit:
      title: "Source Unit"
      description: "the unit in which an only numeric value is given, will transform to base unit"
      type: 'string'
      optional: true
      minLength: 1
    round:
      title: "Rounding"
      description: "the value can be rounded in different ways"
      type: 'or'
      optional: true
      or: [
        title: "Arithmetic Rounding"
        description: "a flag which allows arithmetic rounding (till 4 down, from 5 up)
        if set to `true`"
        type: 'boolean'
      ,
        title: "Alternative Rounding"
        description: "the alternative rounding method to be used"
        type: 'string'
        values: ['floor', 'ceil']
      ]
    decimals:
      title: "Decimals"
      description: "the number of decimal digits to round to"
      type: 'integer'
      optional: true
      min: 0
    min:
      title: "Min Value"
      description: "the minimal value to be set"
      type: 'float'
      optional: true
    max:
      title: "Max Value"
      description: "the maximal value to be set"
      type: 'float'
      optional: true
      min: '<<<min>>>'
    toUnit:
      title: "Result Unit"
      description: "the unit to which to transform the value"
      type: 'string'
      optional: true
    format:
      title: "Format"
      description: "the numerical output format to use"
      type: 'string'
      optional: true
    locale:
      title: "Locale"
      description: "the language to be used for locale specific number format"
      type: 'string'
      match: /^[a-z]{2}(?:-[A-Z]{2})?$/
      optional: true
  , rules.baseSchema
