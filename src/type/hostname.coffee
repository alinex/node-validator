###
Hostname
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


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A valid hostname. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  text += "This has to be a valid name according to [RFC 1123](http://tools.ietf.org/html/rfc1123)"
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # subchecks with new sub worker
  worker = new Worker "#{@name}#",
    type: 'string'
    lowerCase: true
    maxLength: 255
    match: ///
      ^
      ( # multiple namne parts
        ( # name part
          [a-zA-Z0-9] # single letter
          |[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9] # multiple letter
        )\. # dot as separator
      )* # multiple matches
      ( # last name part without dot
        [a-zA-Z0-9] # single letter
        |[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9] # multiple letter
      )
      $
      ///
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
  title: "URL"
  description: "an url schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'hostname'
      optional: true
