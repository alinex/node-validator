# Array validator
# =================================================

# Sanitize options:
#
# - `delimiter` - allow value text with specified list separator
#   (it can also be an regular expression)
#
# Check options:
#
# - `notEmpty` - set to true if an empty array is not valid
# - `minLength` - minimum number of entries
# - `maxLength` - maximum number of entries
# - `toArray` - convert scalar values into array
#
# Validating children:
#
# - `èntries` - specification for all entries or as array for each element

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:array')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
async = require 'alinex-async'
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A list. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if work.pos.notEmpty
    text += "It's not allowed to be empty. "
  if work.pos.delimiter?
    text += "You may also give a text or RegExp using '#{work.pos.delimiter}'
      as separator for the individual entries. "
  if work.pos.minLength? and work.pos.maxLength?
    text += "The number of entries have to be between #{work.pos.minLength}
      and #{work.pos.maxLength}. "
  else if work.pos.minLength?
    text += "At least #{work.pos.minLength} elements should be given. "
  else if work.pos.maxLength?
    text += "Not more than #{work.pos.maxLength} elements are allowed. "
  async.parallel [
    (cb) ->
      return cb() unless work.pos.list?
      subtext = "The following entries have a specific format:"
      async.map [0..work.pos.list.length-1], (num, cb) ->
        # run subcheck
        check.describe work.goInto('list', num), (err, text) ->
          return cb err if err
          cb null, "\n- #{num}: #{text.replace /\n/g, '\n  '}"
      , (err, results) ->
        return cb err if err
        cb null, subtext + results.join('') + '\n'
    (cb) ->
      return cb() unless work.pos.entries?
      subtext = "And all other entries have to be:\n- "
      # run subcheck
      check.describe work.goInto('entries'), (err, text) ->
        return cb err if err
        cb null, subtext + (text.replace /\n/g, '\n  ') + '\n'
  ], (err, results) ->
    return cb err if err
    cb null, (text + results.join '').trim() + ' '

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  value = work.value
  # string to array
  if typeof value is 'string' and work.pos.delimiter?
    value = value.split work.pos.delimiter
  if work.pos.toArray and not Array.isArray value
    value = [value]
  # is array
  unless Array.isArray value
    return work.report (new Error "The value has to be an array"), cb
  # not empty
  if work.pos.notEmpty and value.length is 0
    return work.report (new Error "An empty array/list is not allowed"), cb
  # min/macLength
  if work.pos.minLength? and work.pos.minLength is work.pos.maxLength and (
    value.length isnt work.pos.minLength)
    return work.report (new Error "Exactly #{work.pos.minLength} entries are required"), cb
  else if work.pos.minLength? and work.pos.minLength > value.length
    return work.report (new Error "At least #{work.pos.minLength} entries are required as list"), cb
  else if work.pos.maxLength? and work.pos.maxLength < value.length
    return work.report (new Error "Not more than #{work.pos.maxLength} entries
    are allowed as list"), cb
  # values
  unless value.length
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value}"
    return cb null, value
  async.each [0..value.length-1], (num, cb) ->
    # find sub-check
    if work.pos.list?[num]?
      sub = work.goInto 'list', num
      sub.value = sub.value[num]
    else if work.pos.entries?
      sub = work.goInto 'entries'
      sub.value = sub.value[num]
    return cb() unless sub?
    check.run sub, cb
  , (err) ->
    return cb err if err
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
          type: 'array'
          optional: true
        delimiter:
          type: 'or'
          optional: true
          or: [
            type: 'string'
          ,
            type: 'object'
            instanceOf: RegExp
          ]
        toArray:
          type: 'boolean'
          optional: true
        notEmpty:
          type: 'boolean'
          optional: true
        minLength:
          type: 'integer'
          optional: true
          min: 0
        maxLength:
          type: 'integer'
          optional: true
#          min: '<<<minLength>>>'
        list:
          type: 'or'
          optional: true
          or: [
            type: 'object'
          ,
            type: 'array'
          ]
        entries:
          type: 'or'
          or: [
            type: 'object'
          ,
            type: 'array'
          ,
            type: 'string'
          ]

    value: schema
  , cb
