# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:handlebars')
chalk = require 'chalk'
handlebars = require 'handlebars'
require('swag').registerHelpers handlebars
# alinex modules
util = require 'alinex-util'
require('alinex-handlebars').register handlebars
# include classes and helper
check = require '../check'


# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A valid text which may contain handlebar syntax and variables. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  cb null, text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect value ? null}"
      return cb()
  catch error
    return work.report error, cb
  value = work.value
  # check for already converted values
  return cb null, value if typeof value is 'function'
  # sanitize
  unless typeof value is 'string'
    return work.report (new Error "The given value '#{value}' is no integer as needed"), cb
  # compile if handlebars syntax found
  if value.match /\{\{.*?\}\}/
    debug "#{work.debug} compile handlebars"
    template = handlebars.compile value
    fn = (context) ->
      debug "#{work.debug} execute #{util.inspect value}" +
        chalk.grey " with #{util.inspect context}"
      return template context
  else
    fn = -> value
  debug "#{work.debug} result #{util.inspect value ? null}"
  cb null, fn

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: util.extend util.clone(check.base),
        default:
          type: 'string'
          optional: true
    value: schema
  , cb
