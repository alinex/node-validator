# Object validator
# =================================================

# Check options:
#
# - `instanceOf` - only objects of given class type are allowed
# - `mandatoryKeys` - the list of elements which are mandatory
# - `allowedKeys` - gives a list of elements which are also allowed
#   or true to use the list from entries definition
#
# Validating children:
#
# - `entries` - specification for entries

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:object')
async = require 'alinex-async'
util = require 'util'
chalk = require 'chalk'
# alinex modules
array = require('alinex-util').array
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work) ->
  text = 'An object. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  # instanceof
  if work.pos.instanceOf?
    text += "The object has to be an instance of #{work.pos.instanceOf.name}. "
  # same type for all keys
  if work.pos.entries?
    text += "The entries should be:"
    if Array.isArray work.pos.entries
      entries = work.goInto 'entries'
      for num in [0..entries.length-1]
        sub = entries.goInto num
        text += "\n- #{sub.key ? 'other'}: " + check.describe(sub).replace /\n/g, '\n  '
    else
      sub = work.goInto 'entries'
      text += "\n- " + check.describe(sub).replace /\n/g, '\n  '
    text += '\n'
  # mandatoryKeys
  mandatoryKeys = work.pos.mandatoryKeys ? []
  if mandatoryKeys and typeof mandatoryKeys is 'boolean'
    # use from entries and keys
    mandatoryKeys = []
    if work.pos.keys?
      mandatoryKeys = mandatoryKeys.concat Object.keys work.pos.keys
    if work.pos.entries?
      for entry in work.pos.entries
        mandatoryKeys.push entry.key if entry.key?
  if mandatoryKeys.length
    text += "The following keys have to be present: #{mandatoryKeys.join ','}"
  # allowedKeys
  allowedKeys = work.pos.allowedKeys ? []
  if allowedKeys and typeof allowedKeys is 'boolean'
    # use from entries and keys
    allowedKeys = []
    if work.pos.keys?
      allowedKeys = allowedKeys.concat Object.keys work.pos.keys
    if work.pos.entries?
      for entry in work.pos.entries
        allowedKeys.push entry.key if entry.key
  if allowedKeys.length
    # remove the already mandatory ones
    list = allowedKeys.filter (e) -> not e in mandatoryKeys
    text += "The following keys are also allowed: #{list.join ','}"
  # subchecks
  if work.pos.keys?
    text += "The following entries have a specific format: "
    for key of work.pos.keys
      text += "\n- #{key}: "
      # run subcheck
      text += check.describe(work.goInto 'keys', key).replace /\n/g, '\n  '
  if work.pos.entries?
    text += "And all keys which are:"
    for rule, i in work.pos.entries
      if rule.key?
        text += "\n- matching #{rule.key}: "
      else
        text += "\n- other keys: "
      # run subcheck
      text += check.describe(work.goInto 'entries', i).replace /\n/g, '\n  '
  text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return cb work.report err
  value = work.value
  # instanceof
  if work.pos.instanceOf?
    unless value instanceof work.pos.instanceOf
      return cb work.report new Error "An object of #{work.pos.instanceOf.name} is needed as value"
  # is object
  if typeof value isnt 'object' or Array.isArray value
    return cb work.report new Error "The value has to be an object"
  # check object keys
  keys = Object.keys value
  # check mandatoryKeys
  mandatoryKeys = work.pos.mandatoryKeys ? []
  if mandatoryKeys and typeof mandatoryKeys is 'boolean'
    # use from entries and keys
    mandatoryKeys = []
    if work.pos.keys?
      mandatoryKeys = mandatoryKeys.concat Object.keys work.pos.keys
    if work.pos.entries?
      for entry in work.pos.entries
        mandatoryKeys.push entry.key if entry.key?
  for mandatory in mandatoryKeys
    if mandatory instanceof RegExp
      fail = true
      for key of value
        if key.matches mandatory
          fail = false
          break
      if fail
        return cb work.report new Error "The mandatory key '#{key}' is missing"
    else
      unless value[mandatory]?
        return cb work.report new Error "The mandatory key '#{mandatory}' is missing"
  # check allowedKeys
  allowedKeys = work.pos.allowedKeys ? []
  if allowedKeys and typeof allowedKeys is 'boolean'
    # use from entries and keys
    allowedKeys = []
    if work.pos.keys?
      allowedKeys = allowedKeys.concat Object.keys work.pos.keys
    if work.pos.entries?
      for entry in work.pos.entries
        allowedKeys.push entry.key if entry.key
  if allowedKeys.length
    for key of value
      isAllowed = false
      for allow in allowedKeys
        if key is allow or (allow instanceof RegExp and key.match allow)
          isAllowed = true
          break
      unless isAllowed
        for allow in mandatoryKeys
          if key is allow or (allow instanceof RegExp and key.match allow)
            isAllowed = true
            break
      unless isAllowed
        return cb work.report new Error "The key '#{key}' is not allowed"
  # values
  async.each Object.keys(value), (key, cb) ->
    # find sub-check
    if work.pos.keys?[key]?
      sub = work.goInto 'keys', key
      sub.value = sub.value[key]
    else if work.pos.entries?
      for rule, i in work.pos.entries
        if rule.key?.match key
          sub = work.goInto 'entries', i
          sub.value = sub.value[key]
          break
        else
          sub = work.goInto 'entries', i
          sub.value = sub.value[key]
    return cb() unless sub?
    #cb()
    check.run sub, cb
  , (err) ->
    return cb err if err
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value}"
    cb null, value

exports.selfcheck = ->
  type: 'object'
  allowedKeys: true
  entries:
    type:
      type: 'string'
    title:
      type: 'string'
      optional: true
    description:
      type: 'string'
      optional: true
    optional:
      type: 'boolean'
      optional: true
    default:
      type: 'object'
      optional: true
    instanceOf:
      type: 'function'
      class: true
      optional: true
    mandatoryKeys:
      type: 'array'
      optional: true
      entries:
        type: 'string'
    allowedKeys:
      type: 'any'
      optional: true
      entries: [
        type: 'boolean'
      ,
        type: 'array'
        entries:
          type: 'string'
      ,
        type: 'regexp'
      ]
    entries:
      type: 'object'
      optional: true
