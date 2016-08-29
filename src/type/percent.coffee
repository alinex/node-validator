###
Percent
=================================================
Number validation like float but specified for percent and other fraction numbers
like per mille...

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

#3 Possible Units

- '%' - percent value - 10^-2^ = 1 part in 100
- '‰' - per mille value - 10^-3^ = 1 part in 1000
- '‱', 'bp' - basis point - 10^-4^ = 1 part in 10000
- 'pcm' - per cent mille - 10^-5^ = 1 part in 100000
- 'ppm' - parts per million - 10^-6^
- 'ppb' - parts per billion - 10^-9^
- 'ppt' - parts per trillion - 10^-12^
- 'ppq' - parts per quadrillion - 10^-15^


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node modules
# -------------------------------------------------
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'
Worker = require '../helper/worker'


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
  text = 'A percentage value as decimal like 0.3 but it may be given
  as percent or per mille value text like 30% or 30‰, too. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  # unit
  if @schema.unit
    text += "If no other unit given the number will be interpreted as #{@schema.unit}. "
  if @schema.toUnit
    text += "The value will be returned as #{@schema.toUnit}. "
  # subchecks with new sub worker
  worker = new Worker "#{@name}:subtype",
    type: 'float'
    round: @schema.round
    decimals: @schema.decimals
    min: @schema.min
    max: @schema.max
    format: @schema.format
    locale: @schema.locale
  , @context, @dir, @value
  worker.describe (err, subtext) ->
    return cb err if err
    cb null, text + subtext

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # add units
  if @schema.unit?
    if typeof @value is 'number' or
    (typeof @value is 'string' and @value.match /^\s*[+-]?\s*\d+(\.\d*)?\s*$/)
      @value = "" + @value + @schema.unit
  # convert units
  if typeof @value is 'string'
    # sanitize string
    value = @value
    value = if @schema.sanitize then value.replace /^.*?([-+]?\d+\.?\d*).*?$/, '$1'
    else value.replace /(\d+)[^0-9]*?$/, '$1'
    value = Number value
    # convert from unit
    if match = @value.match /^(.*?)([%‰]|bp|pcm|pp[mbtq])$/
      switch match[2]
        when '%' then value /= 100
        when '‰' then value /= 1000
        when '‱', 'bp' then value /= 10000
        when 'pcm' then value /= 100000
        when 'ppm' then value /= 1000000
        when 'ppb' then value /= 1000000000
        when 'ppt' then value /= 1000000000000
        when 'ppq' then value /= 1000000000000000
    else unless @value.match /\d\s*$/
      return @sendError "The value can't be parsed, maybe an unknown unit was used", cb
    @value = value
  # convert to unit
  if @schema.toUnit
    switch @schema.toUnit
      when '%' then @value *= 100
      when '‰' then @value *= 1000
      when '‱', 'bp' then @value *= 10000
      when 'pcm' then @value *= 100000
      when 'ppm' then @value *= 1000000
      when 'ppb' then @value *= 1000000000
      when 'ppt' then @value *= 1000000000000
      when 'ppq' then @value *= 1000000000000000
  # subchecks with new sub worker
  worker = new Worker "#{@name}:subtype",
    type: 'float'
    round: @schema.round
    decimals: @schema.decimals
    min: @schema.min
    max: @schema.max
    format: @schema.format
    locale: @schema.locale
  , @context, @dir, @value
  worker.check (err) =>
    return cb err if err
    @value = worker.value
    # done checking and sanuitizing
    @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Percent"
  description: "a percent schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend rules.baseSchema,
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
      description: "the unit in which an only numeric value is given, will transform to base value"
      type: 'string'
      optional: true
      values: ['%', '‰', '‱', 'bp', 'pcm', 'ppm', 'ppb', 'ppt', 'ppq']
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
      values: ['%', '‰', '‱', 'bp', 'pcm', 'ppm', 'ppb', 'ppt', 'ppq']
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
