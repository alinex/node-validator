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
#
# Validating children:
#
# - `èntries` - specification for all entries or as array for each element

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:array')
async = require 'alinex-async'
util = require 'util'
chalk = require 'chalk'
# include classes and helper
rules = require '../rules'
ValidatorCheck = require '../check'

module.exports = array =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A list. '
      text += rules.describe.optional options
      text = text.replace /\. It's/, ' which is'
      text += array.describe.notempty options
      text += array.describe.string options
      text += array.describe.minmax options
      if options.entries?
        if Array.isArray options.entries
          text += "Entries should contain:"
          for entry, num in options.entries
            if options.entries[num]
              text += "\n- #{num}:"
              text += "\n  " + ValidatorCheck.describe(options.entries[num]).replace /\n/g, '\n  '
            else
              text += "\n- #{num}: Free input without specification. "
        else
          text += "All entries should be:\n"
          text += "#{ValidatorCheck.describe options.entries} ".replace /\n/g, '\n  '
      text

    notempty: (options) ->
      if options.notEmpty
        return "It's not allowed to be empty. "
      ''

    string: (options) ->
      if options.delimiter?
        return "You may also give a text or RegExp using '#{options.delimiter}'
          as separator for the individual entries. "
      ''

    minmax: (options) ->
      if options.minLength? and options.maxLength?
        return "The number of entries have to be between #{options.minLength}
          and #{options.maxLength}. "
      else if options.minLength?
        return "At least #{options.minLength} elements should be given. "
      else if options.maxLength?
        return "Not more than #{options.maxLength} elements are allowed. "
      ''


  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # sanitize
      value = rules.sync.optional check, path, options, value
      return value unless value?
      value = array.sync.string check, path, options, value
      for method in ['array', 'notempty', 'minmax']
        value = array.sync[method] check, path, options, value
      # end processing if no entries to check
      unless options.entries? and value.length
        return value
      # check entries
      for subvalue, i in value
        suboptions = if Array.isArray options.entries
          options.entries[i]
        else
          options.entries
        continue unless suboptions?
        # run subcheck
        value[i] = check.subcall path.concat(i), suboptions, subvalue
      # done return resulting value
      value

    # ### Convert string
    string: (check, path, options, value) ->
      # sanitize
      if typeof value is 'string' and options.delimiter?
        value = value.split options.delimiter
      value

    array: (check, path, options, value) ->
      unless Array.isArray value
        throw check.error path, options, value,
        new Error "The value has to be an array"
      value

    notempty: (check, path, options, value) ->
      if options.notEmpty and value.length is 0
        throw check.error path, options, value,
        new Error "An empty array/list is not allowed"
      value

    minmax: (check, path, options, value) ->
      if options.minLength? and options.minLength is options.maxLength and (
        value.length isnt options.minLength)
        throw check.error path, options, value,
        new Error "Exactly #{options.minLength} entries are required"
      else if options.minLength? and options.minLength > value.length
        throw check.error path, options, value,
        new Error "At least #{options.minLength} entries are required as list"
      else if options.maxLength? and options.maxLength < value.length
        throw check.error path, options, value,
        new Error "Not more than #{options.maxLength} entries are allowed as list"
      value

  # Asynchronous check
  # -------------------------------------------------
  async:

    # ### Check Type
    type: (check, path, options, value, cb) ->
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # run sync checks
      try
        # sanitize
        value = rules.sync.optional check, path, options, value
        return cb null, value unless value?
        value = array.sync.string check, path, options, value
        # validate
        for method in ['array', 'notempty', 'minmax']
          value = array.sync[method] check, path, options, value
      catch err
        return cb err
      # end processing if no entries to check
      unless options.entries? and value.length
        return cb null, value
      # check entries
      return async.each [0..value.length-1], (i, cb) ->
        suboptions = if Array.isArray options.entries
          options.entries[i]
        else
          options.entries
        return cb() unless suboptions?
        # run subcheck
        check.subcall path.concat(i), suboptions, value[i], (err, result) ->
          # check response
          return cb err if err
          value[i] = result
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
        optional:
          type: 'boolean'
          optional: true
        default:
          type: 'array'
          optional: true
        delimiter:
          type: 'any'
          optional: true
          entries: [
            type: 'string'
          ,
            type: 'object'
            instanceOf: RegExp
          ]
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
          min:
            reference: 'relative'
            source: '<minLength'
        entries:
          type: 'any'
          optional: true
          entries: [
            type: 'object'
          ,
            type: 'array'
            entries:
              type: 'object'
          ]
    , options
    # Check type specific
    return unless options.entries
    if Array.isArray options.entries
      num = 0
      for entry in options.entries
        validator.selfcheck "#{name}.entries[#{num++}]", entry
    else
      validator.selfcheck "#{name}.entries", options.entries

