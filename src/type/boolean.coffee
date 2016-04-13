# Boolean value validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:boolean')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# Configuration
# -------------------------------------------------
valuesTrue = ['true', '1', 'on', 'yes', '+', 1, true]
valuesFalse = ['false', '0', 'off', 'no', '-', 0, false]

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  # get possible values
  vTrue = valuesTrue.map(util.inspect).join ', '
  vFalse = valuesFalse.map(util.inspect).join ', '
  # combine into message
  text = "A boolean value, which will be true for #{vTrue} and
  will be considered as false for #{vFalse}. "
  text += check.optional.describe work
  if work.pos.format
    text += "The values #{work.pos.format.join ', '} will be used for output. "
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
  # sanitize
  value = value.trim().toLowerCase() if typeof value is 'string'
  # boolean values check
  if value in valuesTrue
    value = work.pos.format?[1] ? true
    debug "#{work.debug} result #{value}"
    return cb null, value
  if value in valuesFalse
    value = work.pos.format?[0] ? false
    debug "#{work.debug} result #{value}"
    return cb null, value
  # failed
  work.report (new Error "No boolean value given"), cb

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'boolean'
          optional: true
        format:
          type: 'array'
          minLength: 2
          maxLength: 2
          optional: true
    value: schema
  , cb
