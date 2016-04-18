# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:hostname')
chalk = require 'chalk'
# alinex modules
util = require 'alinex-util'
# include classes and helper
check = require '../check'

subcheck =
  type: 'string'
  lowerCase: true
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
    # no error in string describe possible, so go on
    cb null, text + subtext

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
      keys: util.extend util.clone(check.base),
        default: subcheck
    value: schema
  , cb
