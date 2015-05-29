# Boolean value validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:boolean')
util = require 'util'
chalk = require 'chalk'
# include classes and helper
check = require '../check'

# Configuration
# -------------------------------------------------
valuesTrue = ['true', '1', 'on', 'yes', '+', 1, true]
valuesFalse = ['false', '0', 'off', 'no', '-', 0, false]

# Type implementation
# -------------------------------------------------
exports.describe = (work) ->
  # get possible values
  vTrue = valuesTrue.map(util.inspect).join ', '
  vFalse = valuesFalse.map(util.inspect).join ', '
  # combine into message
  text = "A boolean value, which will be true for #{vTrue} and
  will be considered as false for #{vFalse}. "
  text += check.optional.describe work

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return cb work.report err
  value = work.value
  # sanitize
  value = value.trim().toLowerCase() if typeof value is 'string'
  # boolean values check
  if value in valuesTrue
    debug "#{work.debug} result #{util.inspect true}"
    return cb null, true
  if value in valuesFalse
    debug "#{work.debug} result #{util.inspect false}"
    return cb null, false
  # failed
  cb work.report new Error "No boolean value given"

exports.selfcheck =
  type: 'object'
  allowedKeys: true
  entries:
    type:
      type: 'string'
    title:
      type: 'string'
      optional: true
    description:
      type: 'string'
      optional: true
    optional:
      type: 'boolean'
      optional: true
    default:
      type: 'boolean'
      optional: true


