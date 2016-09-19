###
RegExp
=================================================
Checking regular expressions.

Check options:
- `optional` - `Boolean` the value must not be present (will return null)


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


# Setup
# -------------------------------------------------

# check with other type
subcheck =
  type: 'or'
  or: [
    type: 'object'
    instanceOf: RegExp
  ,
    type: 'string'
    match: /^\/.*?\/[gim]*$/
  ]


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A valid regular expression. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  # subchecks with new sub worker
  worker = new Worker "#{@name}#", subcheck, @context, @value
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
  worker = new Worker "#{@name}#", subcheck, @context, @value
  worker.check (err) ->
    return cb err if err
    # if it already is an regexp return it
    return @sendSuccess cb if @value instanceof RegExp
    # transform into regexp
    parts = @value.match /^\/(.*?)\/([gim]*)$/
    try
      @value = new RegExp parts[1], parts[2]
    catch error
      return @sendError error.message, cb
    # done return resulting value
    return @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "RegExp"
  description: "a regexp schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'regexp'
      optional: true
  , rules.baseSchema
