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
async = require 'async'
util = require 'util'
# include classes and helper
rules = require '../rules'
ValidatorCheck = require '../check'

module.exports = object =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'Here an object have to be given. '
      text += rules.describe.optional options
      text += object.describe.instanceof options
      text += object.describe.keys options
      if options.entries?
        if options.entries.check?
          text += "All entries should be:\n> #{ValidatorCheck.describe options.entries} "
        else
          text += "Entries should contain:\n"
          for entry, num in options.entries
            if options.entries[key]?
              text += "\n- #{key} - #{ValidatorCheck.describe options.entries[key]} "
            else
              text += "\n- #{key} - Free input without specification. "
      text

    instanceof: (options) ->
      if options.instanceOf?
        return "The object has to be an instance of #{options.instanceOf}. "
      ''

    keys: (options) ->
      text = ''
      if options.mandatoryKeys?
        text += "The keys #{options.mandatoryKeys} have to be included. "
      if options.allowedKeys?
        text += "The keys #{options.allowedKeys} are optional. "
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}", util.inspect(options).grey
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
        keys = Object.keys(options.entries).concat Object.keys value
        keys = keys.filter (item, pos, self) -> return self.indexOf(item) == pos
        for key in keys
          suboptions = if typeof options.entries.type is 'string'
            options.entries
          else
            options.entries[key]
          continue unless suboptions?
          # run subcheck
          value[key] = check.subcall path.concat(key), suboptions, value[key]
      value = object.sync.keys check, path, options, value
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
      allowedKeys = allowedKeys.concat options.allowedKeys if options.allowedKeys?
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
      debug "check #{util.inspect value} in #{check.pathname path}", util.inspect(options).grey
      # run sync checks
      try
        # sanitize
        value = rules.sync.optional check, path, options, value
        return cb null, value unless value?
        # validate
        for method in ['instanceof', 'object', 'keys']
          value = object.sync[method] check, path, options, value
      catch err
        return cb err
      # end processing if no entries to check
      unless options.entries?
        return cb null, value
      # check entries
      return async.each Object.keys(value), (key, cb) ->
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

