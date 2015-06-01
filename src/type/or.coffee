# Validator to match any of the possibilities
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:or')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
async = require 'alinex-async'
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = "At least one of the following checks have to succeed:"
  async.map [0..work.pos.or.length-1], (num, cb) ->
    # run subcheck
    check.describe work.goInto('or', num), (err, text) ->
      return cb err if err
      cb null, "\n- #{text.replace /\n/g, '\n  '}"
  , (err, results) ->
    return cb err if err
    text += results.join('') + '\n'
    text += check.optional.describe work
    cb null, text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  # run async checks
  error = []
  async.map [0..(work.pos.or.length-1)], (num, cb) ->
    check.run work.goInto('or', num), (err, result) ->
      error[num] = err if err
      return cb() if err
      cb null, result
  , (err, results) ->
    for result in results
      return cb null, result if result?
    # check response
    return work.report (new Error "None of the alternatives are matched
      (#{error.map((e) -> e.message).join('/ ').trim()})"), cb

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        or:
          type: 'array'
          list:
            type: 'object'
    value: schema
  , cb

