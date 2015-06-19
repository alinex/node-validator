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
  text = 'An object. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  # instanceof
  if work.pos.instanceOf?
    text += "The object has to be an instance of class #{work.pos.instanceOf.name}. "
  text = text.replace /object\. The object/, 'object which'
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
    text += "The following keys have to be present: #{mandatoryKeys.join ', '}. "
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
    if list.length
      text += "And the following keys are also allowed: #{list.join ', '}. "
  # subchecks
  async.parallel [
    (cb) ->
      return cb() unless work.pos.keys?
      subtext = "The following entries have a specific format: "
      async.map Object.keys(work.pos.keys), (key, cb) ->
        # run subcheck
        check.describe work.goInto(['keys', key]), (err, text) ->
          return cb err if err
          cb null, "\n- #{key}: #{text.replace /\n/g, '\n  '}"
      , (err, results) ->
        return cb err if err
        cb null, subtext + results.join('') + '\n'
    (cb) ->
      return cb() unless work.pos.entries?
      subtext = "And all other keys which are: "
      async.map [0..work.pos.entries.length-1], (num, cb) ->
        rule = work.pos.entries[num]
        if rule.key?
          ruletext = "\n- matching #{rule.key}: "
        else
          ruletext = "\n- other keys: "
        # run subcheck
        check.describe work.goInto(['entries', num]), (err, text) ->
          return cb err if err
          cb null, ruletext + text.replace /\n/g, '\n  '
      , (err, results) ->
        return cb err if err
        cb null, subtext + results.join('') + '\n'
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
  # instanceof
  if work.pos.instanceOf?
    unless value instanceof work.pos.instanceOf
      return work.report (new Error "An object of #{work.pos.instanceOf.name} is
        needed as value"), cb
  # is object
  if typeof value isnt 'object' or Array.isArray value
    return work.report (new Error "The value has to be an object"), cb
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
        return work.report (new Error "The mandatory key '#{key}' is missing"), cb
    else
      unless value[mandatory]?
        return work.report (new Error "The mandatory key '#{mandatory}' is missing"), cb
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
        return work.report (new Error "The key '#{key}' is not allowed"), cb
  # values
  unless Object.keys(value).length
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value}"
    return cb null, value
  async.each Object.keys(value), (key, cb) ->
    # find sub-check
    if work.pos.keys?[key]?
      sub = work.goInto ['keys', key], [key]
    else if work.pos.entries?
      for rule, i in work.pos.entries
        if rule.key?.match key
          sub = work.goInto ['entries', i], [key]
          break
        else
          sub = work.goInto ['entries', i], [key]
    else
      # keys that have no specification
      name = work.spec.name ? 'value'
      path = work.path.concat key
      name += "/#{path.join '/'}"
      sub = work.goInto [key], [key]
      sub.pos =
        type: switch
          when Array.isArray sub.value
            'array'
          when typeof sub.value is 'object'
            'object'
          else
            'any'
        optional: true
    check.run sub, (err, result) ->
      return cb err if err
      value[key] = result
      cb()
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
          type: 'object'
          optional: true
        instanceOf:
          type: 'function'
          optional: true
        mandatoryKeys:
          type: 'or'
          optional: true
          or: [
            type: 'boolean'
          ,
            type: 'array'
            entries:
              type: 'or'
              or: [
                type: 'string'
              ,
                type: 'regexp'
              ]
          ]
        allowedKeys:
          type: 'or'
          optional: true
          or: [
            type: 'boolean'
          ,
            type: 'array'
            entries:
              type: 'or'
              or: [
                type: 'string'
              ,
                type: 'regexp'
              ]
          ]
        entries:
          type: 'array'
          optional: true
        keys:
          type: 'object'
          optional: true
    value: schema
  , cb

