# Date check
# =================================================

# Check options:
#
# - `part` - 'date', 'time' or 'datetime'
#
# - `min` - (integer) the date should be after
# - `max` - (integer) the date should be before
# - format
# - language array

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:datetime')
util = require 'util'
chalk = require 'chalk'
moment = require 'moment'
chrono = require 'chrono-node'

# include alinex packages
# alinex modules
{object, number} = require 'alinex-util'
# include classes and helper
check = require '../check'

# Optimize options setting
# -------------------------------------------------
optimize = (schema) ->
  schema.part ?= 'datetime'
  schema

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  work.pos = optimize work.pos
  # combine into message
  text = "A #{work.pos.part} is needed given as calendar #{work.pos.part}
  or in natural language."
  text += check.optional.describe work
  cb null, text



exports.run = (work, cb) ->
  work.pos = optimize work.pos
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect value ? null}"
      return cb()
  catch err
    return work.report err, cb

  # parse date
  moment.createFromInputFallback = (config) ->
    config._d = chrono.parseDate work.value
  console.log '??? ', work.value
  m = moment work.value
  unless m.isValid()
    return work.report (new Error "The given text '#{work.value}' is not parse able
      as date/time."), cb
  # format value
  value = m.toDate()
  console.log '--->', value

  # try moment parsing
  cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'datetime'
          optional: true
        part:
          type: 'string'
          optional: true
          values: ['date', 'time', 'datetime']
          default: 'datetime'
        min:
          type: 'datetime'
          part: '<<<part>>>'
          optional: true
        max:
          type: 'datetime'
          part: '<<<part>>>'
          optional: true
          min: '<<<min>>>'
    value: schema
  , cb
