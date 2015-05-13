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
# include classes and helper
rules = require '../rules'
ValidatorCheck = require '../check'

module.exports = object =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'An object. '
      text += rules.describe.optional options
      text = text.replace /\. It's/, ' which is'
      text += object.describe.instanceof options
      text += object.describe.keys options

    instanceof: (options) ->
      if options.instanceOf?
        return "The object has to be an instance of #{options.instanceOf.name}. "
      ''

    keys: (options) ->
      text = ''
      if options.mandatoryKeys?
        text += "The #{if options.mandatoryKeys.length>1 then 'keys' else 'key'}
        '#{options.mandatoryKeys.join "', '"}' have to be included. "
      if options.allowedKeys
        if typeof options.allowedKeys is 'boolean'
          text += "Only specified keys are allowed. "
        else
          text += "The #{if options.allowedKeys.length>1 then 'keys' else 'key'}
          '#{options.allowedKeys.join "', '"}'
          #{if options.allowedKeys.length>1 then 'are' else 'is'} also allowed. "
      if typeof options.entries?.type is 'string'
        text += "The entries should be:\n"
        text += ValidatorCheck.describe options.entries.type
      else if options.entries?
        text += "The following entries have a specific format:"
        for key in Object.keys options.entries
          suboptions = if typeof options.entries.type is 'string'
            options.entries
          else
            options.entries[key]
          continue unless suboptions?
          # run subcheck
          text += "\n- #{key}:"
          text += "\n  " + ValidatorCheck.describe(suboptions).replace /\n/g, '\n  '
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "#{check.pathname path} check: #{util.inspect(value).replace /\n/g, ''}"
      , chalk.grey util.inspect options
      # sanitize
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # validate
      for method in ['instanceof', 'object']
        value = object.sync[method] check, path, options, value
      # end processing if no entries to check
      if options.instanceOf?
        return value
      # check entries
      if options.entries?
        keys = Object.keys value
        unless typeof options.entries.type is 'string'
          keys = keys.concat Object.keys options.entries
        keys = keys.filter (item, pos, self) -> return self.indexOf(item) == pos
        for key in keys
          suboptions = if typeof options.entries.type is 'string'
            options.entries
          else
            options.entries[key]
          continue unless suboptions?
          # run subcheck
          value[key] = check.subcall path.concat(key), suboptions, value[key]
      # check the used keys
      value = object.sync.keys check, path, options, value
      # check also for references in unspecified keys
      hasErr = false
      for key of value
        try
          if Array.isArray value[key]
            value[key] = check.subcall path.concat(key), null, value[key]
          else if typeof value[key] is 'object'
            value[key] = check.subcall path.concat(key), null, value[key]
          else
            value[key] = check.subcall path.concat(key), null, value[key]
        catch err
          if err.message is 'EAGAIN'
            hasErr = err
          else
            throw err
      throw hasErr if hasErr
      # done return resulting value
      value

    instanceof: (check, path, options, value) ->
      # validate
      if options.instanceOf?
        unless value instanceof options.instanceOf
          throw check.error path, options, value,
          new Error "An object of #{options.instanceOf.name} is needed as value"
      value

    object: (check, path, options, value) ->
      if typeof value isnt 'object' or value instanceof Array
        throw check.error path, options, value,
          new Error "The value has to be an object"
      value

    keys: (check, path, options, value) ->
      # add mandatory keys to allowed keys
      allowedKeys = []
      if options.allowedKeys? and typeof options.allowedKeys isnt 'boolean'
        allowedKeys = allowedKeys.concat options.allowedKeys
      if options.entries?
        for key in Object.keys options.entries
          allowedKeys.push key unless allowedKeys[key]
      if options.mandatoryKeys?
        for entry in options.mandatoryKeys
          allowedKeys.push entry unless allowedKeys[entry]
      # check
      if options.allowedKeys? and (options.allowedKeys.length or options.allowedKeys is true)
        for key of value
          unless key in allowedKeys
            throw check.error path, options, value,
            new Error "The key '#{key}' is not allowed"
      if options.mandatoryKeys?
        for key in options.mandatoryKeys
          keys = Object.keys value
          unless key in keys
            opt = options.entries?[key] ? options.entries ? {}
            throw check.error path, options, value,
            new Error "The key '#{key}' is missing"
      value

  # Asynchronous check
  # -------------------------------------------------
  async:

    # ### Check Type
    type: (check, path, options, value, cb) ->
      debug "#{check.pathname path} check: #{util.inspect(value).replace /\n/g, ''}"
      , chalk.grey util.inspect options
      # run sync checks
      try
        # sanitize
        value = rules.sync.optional check, path, options, value
        return cb null, value unless value?
        # validate
        for method in ['instanceof', 'object']
          value = object.sync[method] check, path, options, value
      catch err
        return cb err
      # end processing if no entries to check
      if options.instanceOf?
        return cb null, value
      # check entries
      unless options.entries?
        try
          value = object.sync.keys check, path, options, value
        catch err
          return cb err
        # done return results
        return cb null, value
      keys = Object.keys value
      unless typeof options.entries.type is 'string'
        keys = keys.concat Object.keys options.entries
      keys = keys.filter (item, pos, self) -> return self.indexOf(item) == pos
      return async.each keys, (key, cb) ->
        suboptions = if typeof options.entries.type is 'string'
          options.entries
        else
          options.entries[key]
        return cb() unless suboptions?
        # run subcheck
        check.subcall path.concat(key), suboptions, value[key], (err, result) ->
          # check response
          return cb err if err
          value[key] = result
          cb()
      , (err) ->
        try
          value = object.sync.keys check, path, options, value
        catch err
          return cb err
        # done return results
        cb err, value


  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
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
          ]
        entries:
          type: 'object'
          optional: true
    , options
    # Check type specific
    return unless options.entries
    if typeof options.entries.type is 'string'
      return validator.selfcheck "#{name}.entries", options.entries
    for key, entry of options.entries
      validator.selfcheck "#{name}.entries[#{key}]", entry
