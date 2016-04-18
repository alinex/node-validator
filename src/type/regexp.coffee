# RegExp validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:regexp')
chalk = require 'chalk'
# alinex modules
util = require 'alinex-util'
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
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect value ? null}"
      return cb()
  catch error
    return work.report error, cb
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
      debug "#{work.debug} result #{util.inspect value ? null}"
      return cb null, value
    # transform into regexp
    parts = value.match /^\/(.*?)\/([gim]*)$/
    try
      value = new RegExp parts[1], parts[2]
    catch error
      return work.report error, cb
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
          type: 'regexp'
          optional: true
    value: schema
  , cb
