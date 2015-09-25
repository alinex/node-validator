# Date check
# =================================================

# Check options:
#
# - `part` - 'date', 'time' or 'datetime'
#
# - `min` - (integer) the date should be after
# - `max` - (integer) the date should be before
# - format


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:datetime')
util = require 'util'
chalk = require 'chalk'
moment = require 'moment'
chrono = require 'chrono'

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

#day = moment value
#unless day.isValid()
#date = chrono.parseDate value


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

  # first check using chrono
  # try moment parsing
  cb null, work.value

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
