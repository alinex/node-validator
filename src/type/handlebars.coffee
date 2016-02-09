# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:handlebars')
util = require 'util'
chalk = require 'chalk'
handlebars = require 'handlebars'
moment = require 'moment'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# Handlebars Helper
# -------------------------------------------------
# Find more at https://github.com/assemble/handlebars-helpers/tree/master/lib/helpers

helper =

  # ### dateFormat
  #
  # format an ISO date using Moment.js - http://momentjs.com/
  # https://github.com/assemble/handlebars-helpers/tree/master/lib/helpers
  #
  #     date = new Date()
  #     {{dateFormat date "MMMM YYYY"}}
  #     # January 2016
  #     {{dateFormat date "LL"}}
  #     # January 18, 2016
  dateFormat: ->
    args = [].slice.call(arguments)
    [date, format] = args[0..-2]
    moment(new Date date).format format ? 'MMM Do, YYYY'

  # ### join
  #
  # Joins all elements of a collection into a string
  # using a separator if specified.
  #
  #     array = [1, 2, 3]
  #     {{join array}}
  #     # '1 2 3'
  #     {{join array ", "}}
  #     # '1, 2, 3'
  join: ->
    args = [].slice.call(arguments)
    [array, separator] = args[0..-2]
    array.join separator ? ' '

# register helper
for key, fn of helper
  handlebars.registerHelper key, fn


# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A valid text which may contain handlebar syntax and variables. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  cb null, text

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
  # check for already converted values
  return cb null, value if typeof value is 'function'
  # sanitize
  unless typeof value is 'string'
    return work.report (new Error "The given value '#{value}' is no integer as needed"), cb
  # compile if handlebars syntax found
  if value.match /\{\{.*?\}\}/
    debug "#{work.debug} compile handlebars"
    template = handlebars.compile value
    fn = (context) ->
      debug "#{work.debug} execute #{util.inspect value}" +
        chalk.grey " with #{util.inspect context}"
      return template context
  else
    fn = -> value
  debug "#{work.debug} result #{util.inspect value ? null}"
  cb null, fn

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'string'
          optional: true
    value: schema
  , cb
