# Boolean value validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:any')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = "Any value is valid. "
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  cb null, text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  debug "#{work.debug} result #{util.inspect work.value}"
  cb null, work.value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: check.base
    value: schema
  , cb
