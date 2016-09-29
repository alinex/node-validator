###
Handlebars
=================================================
Validate a possible handlebar template and return the function to directly use it.

A template function or template source or normal text are all valid and result in
returning a function which may be called with a context will return the template's
resulting text.

A text which may contain [handlebars syntax](http://alinex.github.io/develop/lang/handlebars.html)
will be compiled into a function which if called with the context
object will return the resulting text.

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: 'hello {{name}}' # value to check
  schema:             # definition of checks
    type: 'handlebars'
, (err, result) ->
  # then use it
  console.log result
    name: 'alex'
  # this will output 'hello alex'
```

Within the handlebars templates you may use:

- [builtin helpers](http://alinex.github.io/develop/lang/handlebars.html#built-in-helpers)
- additional [handlebars](http://alinex.github.io/node-handlebars) helpers


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
handlebars = require 'handlebars'
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


# Setup
# -------------------------------------------------
require('alinex-handlebars').register handlebars


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A valid text which may contain handlebar syntax and variables. '
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
  # check for already converted values
  return @sendSuccess cb if typeof @value is 'function'
  # sanitize
  unless typeof @value is 'string'
    return @sendError "The given value is no integer as needed", cb
  # compile if handlebars syntax found
  if @value.match /\{\{.*?\}\}/
    @debug "#{@name}: compile handlebars" if @debug.enabled
    template = handlebars.compile @value
    fn = (context) =>
      @debug "#{@name}: execute template with #{util.inspect context}" if @debug.enabled
      return template context
  else
    v = @value
    fn = -> v
  @value = fn
  # done checking and sanuitizing
  @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Handlebars"
  description: "a handlebars schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend {}, rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'or'
      optional: true
      or: [
        title: "Template"
        description: "the default template text to use"
        type: 'string'
      ,
        title: "Function"
        description: "the default function to use"
        type: 'function'
      ]
