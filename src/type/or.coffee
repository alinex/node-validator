# Validator to match any of the possibilities
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:or')
chalk = require 'chalk'
# alinex modules
util = require 'alinex-util'
async = require 'alinex-async'
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = "At least one of the following checks have to succeed:"
  max = work.pos.or.length - 1
  async.map [0..max], (num, cb) ->
    # run subcheck
    check.describe work.goInto(['or', num]), (err, text) ->
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
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect work.value ? null}"
      return cb()
  catch error
    return work.report error, cb
  # run async checks
  error = []
  max = work.pos.or.length - 1
  async.map [0..max], (num, cb) ->
    sub = work.goInto ['or', num]
    check.run sub, (err, result) ->
      error[num] = err if err
      if err
        debug "#{sub.debug} result ##{num}: failed"
        return cb()
      debug "#{sub.debug} result ##{num}: #{util.inspect result}"
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
      keys: util.extend util.clone(check.base),
        default:
          type: 'any'
          optional: true
        or:
          type: 'array'
          list:
            type: 'object'
    value: schema
  , cb
