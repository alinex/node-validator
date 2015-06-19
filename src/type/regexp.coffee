# RegExp validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:regexp')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

subcheck =
  type: 'or'
  or: [
    type: 'object'
    instanceOf: RegExp
  ,
    type: 'string'
    match: /^\/.*?\/[gim]*$/
  ]

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A valid regular expression. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  # subcheck
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.describe
    name: name
    schema: subcheck
  , (err, subtext) ->
    # no error possible in string describe, so go on
    cb null, text + subtext

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  value = work.value
  # first check input type
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.run
    name: name
    value: work.value
    schema: subcheck
  , (err, value) ->
    return cb err if err
    # if it already is an regexp return it
    if value instanceof RegExp
      debug "#{work.debug} result #{util.inspect value}"
      return cb null, value
    # transform into regexp
    parts = value.match /^\/(.*?)\/([gim]*)$/
    try
      value = new RegExp parts[1], parts[2]
    catch err
      return work.report err, cb
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value}"
    cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'regexp'
          optional: true
    value: schema
  , cb


