# Function validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:function')
util = require 'util'
chalk = require 'chalk'
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work) ->
  # combine into message
  text = if work.pos.class?
    "A #{if work.pos.class then 'class' else 'function'} reference. "
  else
    "The value has to be a function/class. "
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return cb work.report err
  value = work.value
  # value check
  unless value instanceof Function
    return cb work.report new Error "No function given as value"
  # done return resulting value
  debug "#{work.debug} result #{util.inspect value}"
  cb null, value

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
      type: 'function'
      optional: true
