###
Boolean
=================================================
The value has to be a boolean. The value will be true for 1, 'true', 'on',
'yes', '+' and it will be considered as false for 0, 'false', 'off', 'no',
'-', null and undefined.
Other values are not allowed.

__Format options:__

- `format` - (list) with the values for false and true

__Example:__

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'boolean'
, (err, result) ->
  # do something
```


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
  keys: util.extend
    format:
      title: "Format"
      description: "the display values for `false` and `true`"
      type: 'array'
      minLength: 2
      maxLength: 2
      optional: true
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'boolean'
      optional: true
