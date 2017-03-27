###
Integer
=================================================
This will check an integer number against a precise definition in which
range it may be.

Sanitize options allowed:
- `sanitize` - `Boolean` remove invalid characters
- `unit` - `String` unit to convert to if no number is given
- `round` - `Boolean|String` rounding of float can be set to true for arithmetic rounding
 or use `floor` or `ceil` for the corresponding methods

Check options:
- `min` - `Integer` the smallest allowed number
- `max` - `Integer` the biggest allowed number
- `inttype` - `Integer|String` the integer is of given type
  (4, 8, 16, 32, 64, 'byte', 'short','long','quad', 'safe')
- `unsigned` - `Boolean` the integer has to be positive

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
- {@link float.coffee}
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

# Define some named integer types wo be given:
#
integerTypes =
  byte: 8
  short: 16
  long: 32
  safe: 53
  quad: 64


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  # combine into message
  text = "An integer value. "
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
    text += "The value will be rounded #{type} to an integer. "
  # integer type
  max = min = null
  if @schema.inttype?
    type = integerTypes[@schema.inttype] ? @schema.inttype
    unsigned = if @schema.unsigned then 'an unsigned' else 'a signed'
    text += "Only values in the range of #{unsigned}
      #{if typeof @schema.inttype isnt 'number' then @schema.inttype else type}-integer
      are allowed. "
    unsigned = if @schema.unsigned then 1 else 0
    max = (Math.pow 2, type-1+unsigned)-1
    min = (unsigned-1) * max - 1 + unsigned
  # minmax
  min = @schema.min if @schema.min? and (not min? or @schema.min > min)
  max = @schema.max if @schema.max? and (not max? or @schema.max < max)
  if min? and max?
    text += "The value should be between #{min} and #{max}. "
  else if min?
    text += "The value should be greater than #{min}. "
  else if max?
    text += "The value should be lower than #{max}. "
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
    if @schema.round?
      @value = @value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
    else
      @value = @value.replace /^.*?([-+]?\d+).*?$/, '$1'
  if typeof @value is 'string' and @value.length
    @value = Number @value if @value.length
  # round
  if @schema.round
    @value = switch @schema.round
      when 'ceil' then Math.ceil @value
      when 'floor' then Math.floor @value
      else Math.round @value
  # check integer
  unless @value is (@value | 0)
    return @sendError "The given value is no integer as needed", cb
  # integer type
  max = min = null
  if @schema.inttype
    type = integerTypes[@schema.inttype] ? @schema.inttype
    unsigned = if @schema.unsigned then 1 else 0
    max = (Math.pow 2, type-1+unsigned)-1
    min = (unsigned-1) * max - 1 + unsigned
    if @value < min or @value > max
      return @sendError "The value is out of range for #{@schema.inttype}#{type}-integer", cb
  # minmax
  min = @schema.min if @schema.min? and (not min? or @schema.min > min)
  max = @schema.max if @schema.max? and (not max? or @schema.max < max)
  if min? and @value < min
    return @sendError "The value is to low, it has to be at least #{min}", cb
  if max? and @value > max
    return @sendError "The value is to high, it has to be at #{max} or lower", cb
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
    inttype:
      title: "Integer Type"
      description: "the type (size) of the allowed integer"
      type: 'or'
      optional: true
      or: [
        title: "Byte Size"
        description: "the type of the integer as mnumber of bytes"
        type: 'integer'
      ,
        title: "Named Type"
        description: "the named type (size) of the integer"
        type: 'string'
        values: ['byte', 'short', 'long', 'quad', 'safe']
      ]
    unsigned:
      title: "Unsigned"
      description: "a setting to allow only signed `false` or unsigned integers `true`"
      type: 'boolean'
      optional: true
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
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'integer'
      optional: true
