###
Any
=================================================
The type `any` is only used internally and matches any value. It is used as default
if nothing is specified for an value and makes the checks homogeneous.

`any` has no special options.


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

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  # combine into message
  text = "A value of any type. "
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # done checking
  @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Any"
  description: "any schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend {}, rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'any'
      optional: true
