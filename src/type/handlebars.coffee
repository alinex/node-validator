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
handlebarsIntl = require 'handlebars-intl'
global.Intl = require 'intl'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# ### Setup modules
handlebarsIntl.registerWith handlebars
base =
  intl:
    locales: 'en-US'
    formats:
      date:
        short:
          day: 'numeric'
          month: 'long'
          year: 'numeric'

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
    fn = (context, data) ->
      return template context,
        data: object.extend {}, base, data
  else
    fn = -> return value
  debug "#{work.debug} result #{util.inspect value ? null}"
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
