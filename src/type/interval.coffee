###
Interval
=================================================
A time interval may be given:

- directly as number
- in a string with days, minutes and seconds: `1d 3h 12m 10s 400ms`
- in a time format: `03:20`, `02:18:10.5`

Sanitize options allowed:
- `unit` - `String` type of unit to convert if not integer given
- `round` - `Boolean` rounding can be set to true for arithmetic rounding
 or use `floor` or `ceil` for the corresponding methods
- `decimals` - `Integer` number of decimal digits to round to (defaults to 2)

Check options:
- `min` - `Integer` the smallest allowed number
- `max` - `Integer` the biggest allowed number


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


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
  text = "A time interval as float, in time format or as text which may use a
  combination of values with the units: ms, s, m, h, d. "
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if @schema.unit
    text += "The result will be given as the number of #{@schema.unit}. "
  # subchecks with new sub worker
  worker = @sub "#{@name}#",
    type: 'float'
    round: @schema.round
    decimals: @schema.decimals
    min: @schema.min
    max: @schema.max
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
  # subchecks with new sub worker
  worker = @sub "#{@name}#",
    type: 'or'
    or: [
      type: 'float'
    ,
      type: 'string'
      match: /^\d\d?:\d\d?(:\d\d?)?(\.\d+)?$/
    ,
      type: 'string'
      match: ///
        ^
        (
          ([+-]?\d+(?:\.\d+)?)  # a float
          \s*([smhd]|ms)        # with unit
          \s*                   # separator between values
        )*                      # multiple value pairs
        $
      ///
    ]
  , @value
  worker.check (err) =>
    return cb err if err
    @value = worker.value
    # support time format
    if typeof @value is 'string'
      if @value.trim().match /^(\d\d?)(:\d\d?)(:\d\d?)?(\.\d+)?$/
        parts = @value.split ':'
        @value = "#{parts[0]}h #{parts[1]}m"
        @value += " #{parts[2]}s" if parts.length is 3
      parsed = util.number.parseMSeconds @value
      unit = @schema.unit ? 'ms'
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
      @value = parsed
    # run float check
    worker = @sub "#{@name}#",
      type: 'float'
      round: @schema.round
      decimals: @schema.decimals
      min: @schema.min
      max: @schema.max
    , @value
    worker.check (err) =>
      return cb err if err
      @value = worker.value
      # done checking and sanuitizing
      @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Interval"
  description: "an interval schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    unit:
      title: "Source Unit"
      description: "the unit in which an only numeric value is given, will transform to base value"
      type: 'string'
      optional: true
      values: ['d', 'h', 'm', 's', 'ms']
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
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'float'
      optional: true
