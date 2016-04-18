# Function validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:function')
chalk = require 'chalk'
# alinex modules
util = require 'alinex-util'
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  # combine into message
  text = "The value has to be a function/class. "
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
  # value check
  unless value instanceof Function
    return work.report (new Error "No function given as value"), cb
  # done return resulting value
  debug "#{work.debug} result #{util.inspect value ? null}"
  cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: util.extend util.clone(check.base),
        default:
          type: 'function'
          optional: true
    value: schema
  , cb
