###
Boolean
=================================================


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


# Setup
# -------------------------------------------------
valuesTrue = ['true', '1', 'on', 'yes', '+', 1, true]
valuesFalse = ['false', '0', 'off', 'no', '-', 0, false]


# Exported Methods
# -------------------------------------------------
# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  # get possible values
  vTrue = valuesTrue.map(util.inspect).join ', '
  vFalse = valuesFalse.map(util.inspect).join ', '
  # combine into message
  text = "A boolean value, which will be true for #{vTrue} and
  will be considered as false for #{vFalse}. "
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if @schema.format
    text += "The values #{@schema.format.join ', '} will be used for output. "
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # sanitize
  @value = @value.trim().toLowerCase() if typeof @value is 'string'
  # boolean values check
  if @value in valuesTrue
    @value = @schema.format?[1] ? true
    return @sendSuccess cb
  if @value in valuesFalse
    @value = @schema.format?[0] ? false
    return @sendSuccess cb
  # failed
  @sendError "No boolean value given", cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Boolean"
  description: "a boolean schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'boolean'
      optional: true
    format:
      title: "Format"
      description: "the display values for `false` and `true`"
      type: 'array'
      minLength: 2
      maxLength: 2
      optional: true
