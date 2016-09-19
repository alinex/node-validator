###
Datetime
=================================================

Check options:
- `part` - `String` with: 'date', 'time' or 'datetime'
- `min` - `Integer` the date should be after
- `max` - `Integer` the date should be before
- `format` - `String` how to format result as string
- `range` - `Boolean` the value has to be a range consisting of two dates
- 'locale' - `String` used for formatting
- `toTimezone` - `String` transform date/time to the given timezone


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
async = require 'async'
moment = require 'moment-timezone'
chrono = require 'chrono-node'
# include alinex packages
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


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
  MESZ: 'CEST'
  MEZ: 'CET'

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


# Exported Methods
# -------------------------------------------------

# Initialize schema.
exports.init = ->
  @schema.part ?= 'datetime'

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A valid url (unified resource locator). '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  # combine into message
  text = "A #{@schema.part} is needed given as calendar #{@schema.part}
  or in natural language. "
  if @schema.range
    text += "A range with start and end date is needed. "
  if @schema.timezone
    text += "If no timezone given the time is considert as #{@schema.timezone} time. "
  if @schema.min? and @schema.max?
    text += "The #{@schema.part} should be between #{@schema.min} and
    #{@schema.max}. "
  else if @schema.min?
    text += "The #{@schema.part} should be before #{@schema.min}. "
  else if @schema.max?
    text += "The #{@schema.part} should be after #{@schema.max}. "
  if @schema.format?
    add = []
    add.push @schema.locale if @schema.locale
    add.push @schema.toTimezone if @schema.toTimezone
    text += "The #{@schema.part} will be converted to #{@schema.format}
    #{if add.length then '(' + add.join(' ') + ') ' else ''}format. "
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # parse date
  if @schema.timezone
    @schema.timezone = zones[@schema.timezone] ? @schema.timezone
  if @schema.range?
    results = chrono.parse @value
    if results[0].start? and results[0].end?
      @value = [results[0].start.date(), results[0].end.date()]
    else
      return @sendError "The #{@schema.part} has to be a range", cb
  else
    m = if @schema.timezone
      moment.tz @value, @schema.timezone
    else
      moment @value
    unless m.isValid()
      return @sendError "The given text is not parse able as date/time", cb
    @value = m.toDate()
  # min/max
  if @schema.range?
    if @schema.min? and (@value[0] < @schema.min) or @value[1] < @schema.min
      return @sendError "The #{@schema.part} has to be at or after #{@schema.min}", cb
    if @schema.max? and (@value[0] > @schema.max) or @value[1] > @schema.max
      return @sendError "The #{@schema.part} has to be at or before #{@schema.max}", cb
  else
    if @schema.min? and @value < @schema.min
      return @sendError "The #{@schema.part} has to be at or after #{@schema.min}", cb
    if @schema.max? and @value > @schema.max
      return @sendError "The #{@schema.part} has to be at or before #{@schema.max}", cb

  # format value
  if @schema.toTimezone
    @schema.toTimezone = zones[@schema.toTimezone] ? @schema.toTimezone
  if @schema.range?
    if @schema.format?
      if alias[@schema.part]?[@schema.format]?
        @schema.format = alias[@schema.part][@schema.format]
      for p in [0, 1]
        m = moment @value[p]
        m = m.tz @schema.timezone if @schema.toTimezone
        if @schema.locale?
          m.locale @schema.locale
        @value[p] = switch @schema.format
          when 'unix' then  m.unix()
          else m.format @schema.format
  else
    if @schema.format?
      if alias[@schema.part]?[@schema.format]?
        @schema.format = alias[@schema.part][@schema.format]
      m = moment @value
      if @schema.locale?
        m.locale @schema.locale
      m = m.tz @schema.toTimezone if @schema.toTimezone
      @value = switch @schema.format
        when 'unix' then  m.unix()
        else m.format @schema.format
  # done checking and sanuitizing
  @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Datetime"
  description: "a schema definition for date values"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'datetime'
      optional: true
    range:
      title: "Date Range"
      description: "a flag set to `true` to require a range of start and end date"
      type: 'boolean'
      optional: true
    timezone:
      title: "Timezone"
      description: "the timezone to use if nothing given"
      type: 'string'
      optional: true
    part:
      title: "Part"
      description: "the part of the full date to extract"
      type: 'string'
      optional: true
      values: ['date', 'time', 'datetime']
      default: 'datetime'
    min:
      title: "Minimum Date"
      description: "the oldest allowed date"
      type: 'datetime'
      part: '<<<part>>>'
      optional: true
    max:
      title: "Maximum Date"
      description: "the newest allowed date"
      type: 'datetime'
      part: '<<<part>>>'
      optional: true
      min: '<<<min>>>'
    format:
      title: "Format"
      description: "the moment() format string to use"
      type: 'string'
      optional: true
    toTimezone:
      title: "To Timezone"
      description: "the timezone to which to transform given dates"
      type: 'string'
      optional: true
    locale:
      title: "Locale"
      description: "the locale country code to use for formatting"
      type: 'string'
      match: /^[a-z]{2}(-[A-Z]{2})?$/
      optional: true
  , rules.baseSchema
