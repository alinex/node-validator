###
Byte
=================================================

Sanitize options allowed:
- `unit` - `String` unit to convert to if no number is given
- `round` - `Boolean` rounding can be set to true for arithmetic rounding
 or use `floor` or `ceil` for the corresponding methods

Check options:
- `min` - `Integer` the smalles allowed number
- `max` - `Integer` the biggest allowed number

This supports the units: B, Bytes, b, bps, bits


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
math = require 'mathjs'
# alinex modules
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'
Worker = require '../helper/worker'


# Setup
# ------------------------------------------------
pattern = /^[0-9]+(\.?[0-9]*) *(k|Ki|[MGTPEZY]i?)?([Bb]|bps)?$/

# ### Extend Math.js
# Additional derived binary units are added:
Unit = math.type.Unit
Unit.UNITS.bps =
  name: 'bps'
  base: Unit.BASE_UNITS.BIT
  dimensions: Unit.BASE_UNITS.BIT.dimensions
  prefixes: Unit.PREFIXES.BINARY_SHORT
  value: 1, offset: 0


# Exported Methods
# -------------------------------------------------

# Initialize schema.
exports.init = ->
  @schema.round = true if @schema.decimals and not @schema.round?
  @schema.decimals = 0 if @schema.round and not @schema.decimals?
  @schema.min ?= 0

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A byte value. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  text += "If defined as a text you may use a prefix like: k, M, G, P, T, E, Z, Y
  also with the unit B like '12MB' or '3.7 GiB'. "
  # subchecks with new sub worker
  worker = new Worker "#{@name}#",
    type: 'float'
    round: @schema.round
    decimals: @schema.decimals
    min: @schema.min
    max: @schema.max
  , @context
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
  # support byte format
  if typeof @value is 'string'
    unless @value.trim().match pattern
      return @sendError "A byte value with optional prefixes is needed", cb
    # sanitize string
    @value = @value.trim()
    unit = @schema.unit ? if @value.match /(b|bits|bps)$/ then 'b' else 'B'
    unless @value.match /([bB]|bps)$/
      @value += unit
    @value = math.unit @value
    @value = @value.toNumber unit
  else if typeof @value isnt 'number'
    unless @value is (@value | 0)
      return @sendError "The given value is no byte or float number as needed", cb
  # subchecks with new sub worker
  worker = new Worker "#{@name}#",
    type: if @schema.unit?.match /^[kMGTPEZY]([bB]|bps)$/ then 'float' else 'integer'
    round: @schema.round
    decimals: @schema.decimals
    min: @schema.min
    max: @schema.max
  , @context, @value
  worker.check (err) =>
    return cb err if err
    @value = worker.value
    # done checking and sanuitizing
    @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Byte"
  description: "a definition for number of bytes or bits"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'float'
      optional: true
    unit:
      title: "Source Unit"
      description: "the unit in which an only numeric value is given, will transform to base unit"
      type: 'string'
      default: 'B'
      matches: /^[kMGTPEZY]?([bB]|bps)$/
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
  , rules.baseSchema
