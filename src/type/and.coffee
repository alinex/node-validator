# Validator to match multiple definitions
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:and')
util = require 'util'
chalk = require 'chalk'
# alinex modules
async = require 'alinex-async'
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = "All of the following checks have to succeed:"
  async.map [0..work.pos.and.length-1], (num, cb) ->
    # run subcheck
    check.describe work.goInto('and', num), (err, text) ->
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
  async.eachSeries [0..(work.pos.and.length-1)], (num, cb) ->
    sub = work.goInto('and', num)
    sub.value = work.value
    check.run sub, (err, result) ->
      return cb err if err
      work.value = result
      cb()
  , (err) ->
    return cb err if err
    cb null, work.value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        and:
          type: 'array'
          entries:
            type: 'object'
    value: schema
  , cb
