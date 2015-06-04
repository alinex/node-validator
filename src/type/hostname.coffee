# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:hostname')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

subcheck =
  type: 'string'
  match: ///
    ^
    [a-zA-Z0-9]
    |[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]
    $
    ///

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A valid hostname. '
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
    return cb err if err
    cb null, text + subtext

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  # validate using subcheck
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.run
    name: name
    value: work.value
    schema: subcheck
  , cb

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default: subcheck
    value: schema
  , cb
