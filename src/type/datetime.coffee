# Date check
# =================================================

# Check options:
#
# - `part` - 'date', 'time' or 'datetime'
# - `min` - (integer) the date should be after
# - `max` - (integer) the date should be before
# - `format` - how to format result as string

# - `range` - boolean
# - 'locale' - used for formatting
# - language array

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:datetime')
util = require 'util'
chalk = require 'chalk'
moment = require 'moment-timezone'
chrono = require 'chrono-node'
# include alinex packages
{object} = require 'alinex-util'
async = require 'alinex-async'
# include classes and helper
check = require '../check'

# Setup parsing
# -------------------------------------------------
moment.createFromInputFallback = (config) ->
  config._d = switch config._i.toLowerCase()
    when 'now' then new Date()
    else chrono.parseDate config._i

zones =
  'Eastern Standard Time': 'EST'
  'Eastern Daylight Time': 'EDT'
  'Central Standard Time': 'CST'
  'Central Daylight Time': 'CDT'
  'Mountain Standard Time': 'MST'
  'Mountain Daylight Time': 'MDT'
  'Pacific Standard Time': 'PST'
  'Pacific Daylight Time': 'PDT'
  'Central European Time': 'CET'
  'Central European Summer Time': 'CEST'

alias =
  datetime:
    ISO8601: 'YYYY-MM-DDTHH:mm:ssZ'
    RFC1123: 'ddd, DD MMM YYYY HH:mm:ss z'
    RFC2822: 'ddd, DD MMM YYYY HH:mm:ss ZZ'
    RFC822: 'ddd, DD MMM YY HH:mm:ss ZZ'
    RFC1036: 'ddd, D MMM YY HH:mm:ss ZZ'
#    RFC850:  'dddd, D-MMM-ZZ HH:mm:ss Europe/Paris'
#    COOKIE:  'Friday, 13-Feb-09 14:53:27 Europe/Paris'
  date:
    ISO8601: 'YYYY-MM-DD'


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
    or in natural language. "
    text += check.optional.describe work
    if work.pos.range
      text += "A range with start and end date is needed. "
    if work.pos.timezone
      text += "If no timezone given the time is considert as #{work.pos.timezone} time. "
    if work.pos.min? and work.pos.max?
      text += "The #{work.pos.part} should be between #{work.pos.min} and
      #{work.pos.max}. "
    else if work.pos.min?
      text += "The #{work.pos.part} should be before #{work.pos.min}. "
    else if work.pos.max?
      text += "The #{work.pos.part} should be after #{work.pos.max}. "
    if work.pos.format?
      add = []
      add.push work.pos.locale if work.pos.locale
      add.push work.pos.toTimezone if work.pos.toTimezone
      text += "The #{work.pos.part} will be converted to #{work.pos.format}
      #{if add.length then '(' + add.join(' ') + ') ' else ''}format. "
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
    catch error
      return work.report error, cb

    # parse date
    if work.pos.timezone
      work.pos.timezone = zones[work.pos.timezone] ? work.pos.timezone
    if work.pos.range?
      console.log work.value
      results = chrono.parse work.value
      if results[0].start? and results[0].end?
        value = [results[0].start.date(), results[0].end.date()]
      else
        return work.report (new Error "The #{work.pos.part} has to be a range."), cb
    else
      m = if work.pos.timezone
        moment.tz work.value, work.pos.timezone
      else
        moment work.value
      unless m.isValid()
        return work.report (new Error "The given text '#{work.value}' is not parse able
          as date/time."), cb
      value = m.toDate()

    # min/max
    if work.pos.range?
      if work.pos.min? and value[0] < work.pos.min or value[1] < work.pos.min
        return work.report (new Error "The #{work.pos.part} has to be at or after
          #{work.pos.min}"), cb
      if work.pos.max? and value[0] > work.pos.max or value[1] > work.pos.max
        return work.report (new Error "The #{work.pos.part} has to be at or before
          #{work.pos.max}"), cb
    else
      if work.pos.min? and value < work.pos.min
        return work.report (new Error "The #{work.pos.part} has to be at or after
          #{work.pos.min}"), cb
      if work.pos.max? and value > work.pos.max
        return work.report (new Error "The #{work.pos.part} has to be at or before
          #{work.pos.max}"), cb

    # format value
    if work.pos.toTimezone
      work.pos.toTimezone = zones[work.pos.toTimezone] ? work.pos.toTimezone
    if work.pos.range?
      if work.pos.format?
        if alias[work.pos.part]?[work.pos.format]?
          work.pos.format = alias[work.pos.part][work.pos.format]
        for p in [0, 1]
          m = moment value[p]
          m = m.tz work.pos.timezone if work.pos.toTimezone
          if work.pos.locale?
            m.locale work.pos.locale
          value[p] = switch work.pos.format
            when 'unix' then  m.unix()
            else m.format work.pos.format
    else
      if work.pos.format?
        if alias[work.pos.part]?[work.pos.format]?
          work.pos.format = alias[work.pos.part][work.pos.format]
        m = moment value
        if work.pos.locale?
          m.locale work.pos.locale
        m = m.tz work.pos.toTimezone if work.pos.toTimezone
        value = switch work.pos.format
          when 'unix' then  m.unix()
          else m.format work.pos.format

    # try moment parsing
#    console.log '--->', value
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
        range:
          type: 'boolean'
          optional: true
        timezone:
          type: 'string'
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
        format:
          type: 'string'
          optional: true
        toTimezone:
          type: 'string'
          optional: true
        locale:
          type: 'string'
          match: /^[a-z]{2}(-[A-Z]{2})?$/
          optional: true
    value: schema
  , cb
