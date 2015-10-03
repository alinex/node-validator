# Date check
# =================================================

# Check options:
#
# - `part` - 'date', 'time' or 'datetime'
# - `min` - (integer) the date should be after
# - `max` - (integer) the date should be before

# - `format` - how to format result as string
# - 'locale' - used for formatting

# - language array
# - multiple - allow from-to....

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:datetime')
util = require 'util'
chalk = require 'chalk'
moment = require 'moment'
chrono = require 'chrono-node'
# include alinex packages
{object, number} = require 'alinex-util'
async = require 'alinex-async'
# include classes and helper
check = require '../check'

# Setup parsing
# -------------------------------------------------
moment.createFromInputFallback = (config) ->
  config._d = switch config._i.toLowerCase()
    when 'now' then new Date()
    else chrono.parseDate config._i

# Optimize options setting
# -------------------------------------------------
optimize = (schema, cb) ->
  schema.part ?= 'datetime'
  async.each ['default', 'min', 'max'], (i, cb) ->
    return cb() unless schema[i]?
    check.run
      name: "option-#{}{i}-datetime"
      schema:
        type: 'datetime'
      value: schema[i]
    , (err, result) ->
      return cb err if err
      schema[i] = result
      cb()
  , ->
    cb schema

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  optimize work.pos, (result) ->
    work.pos = result
    # combine into message
    text = "A #{work.pos.part} is needed given as calendar #{work.pos.part}
    or in natural language."
    text += check.optional.describe work
    if work.pos.min? and work.pos.max?
      text += "The #{work.pos.part} should be between #{work.pos.min} and
      #{work.pos.max}. "
    else if work.pos.min?
      text += "The #{work.pos.part} should be before #{work.pos.min}. "
    else if work.pos.max?
      text += "The #{work.pos.part} should be after #{work.pos.max}. "
    if work.pos.format?
      text += "The #{work.pos.part} will be converted to #{work.pos.format}
      #{if work.pos.locale? then '('+work.pos.locale+') ' else ''}format. "
    cb null, text


exports.run = (work, cb) ->
  optimize work.pos, (result) ->
    work.pos = result
    debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.part}"
    debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
    # base checks
    try
      if check.optional.run work
        debug "#{work.debug} result #{util.inspect value ? null}"
        return cb()
    catch err
      return work.report err, cb

    # parse date
#    console.log '??? ', work.value
    m = moment work.value
    unless m.isValid()
      return work.report (new Error "The given text '#{work.value}' is not parse able
        as date/time."), cb
    value = m.toDate()

    # min/max
    if work.pos.min? and value < work.pos.min
      return work.report (new Error "The #{work.pos.part} has to be at after
        #{work.pos.min}"), cb
    if work.pos.max? and value > work.pos.max
      return work.report (new Error "The #{work.pos.part} has to be before
        #{work.pos.max}"), cb

    # format value
    if work.pos.format?
      if work.pos.locale?
        m.locale work.pos.locale
      value = switch work.pos.format
        when 'unix' then  m.unix()
        else m.format work.pos.format

    # try moment parsing
    console.log '--->', value
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

