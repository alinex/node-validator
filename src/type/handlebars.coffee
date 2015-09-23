# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:handlebars')
util = require 'util'
chalk = require 'chalk'
handlebars = require 'handlebars'
# alinex modules
object = require('alinex-util').object
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
      debug "#{work.debug} result #{util.inspect value}"
      return cb()
  catch err
    return work.report err, cb
  value = work.value
  # sanitize
  unless typeof value is 'string'
    return work.report (new Error "The given value '#{value}' is no integer as needed"), cb
  # compile if handlebars syntax found
  if value.match /\{\{.*?\}\}/
    debug "#{work.debug} compile handlebars"
    fn = handlebars.compile value
  else
    fn = -> return value
  debug "#{work.debug} result #{util.inspect value}"
  cb null, fn

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'string'
          optional: true
    value: schema
  , cb

