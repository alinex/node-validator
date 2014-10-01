# Validator to match any of the possibilities
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:any')
async = require 'async'
util = require 'util'
# include classes and helper
rules = require '../rules'
ValidatorCheck = require '../check'

module.exports = any =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = "At least one of the following checks have to succeed:\n"
      for entry in options.entries
        text += "- #{ValidatorCheck.describe entry} ".replace '\n', '\n  '
        text += '\n'
      text += rules.describe.optional options
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
      num = 0
      for suboptions in options.entries
        continue unless suboptions?
        # run subcheck
        try
          return check.subcall path.concat(num++), suboptions, value
        catch err
      # error, nothing matched
      throw check.error path, options, value,
      new Error "None of the alternatives are matched"

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
      catch err
        return cb err
      # run async checks
      async.map [0..(options.entries.length-1)], (num, cb) ->
        suboptions = options.entries[num]
        # run subcheck
        check.subcall path.concat(num), suboptions, value, (err, result) ->
          # check response
          return cb() if err
          cb null, result
      , (err, results) ->
        # check response
        for result in results
          return cb null, result if result?
        cb check.error path, options, value,
        new Error "None of the alternatives are matched"


  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
      type: 'object'
      allowedKeys: ['default']
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
        entries:
          type: 'array'
          entries:
            type: 'object'
    , options
    # Check type specific
    num = 0
    for entry in options.entries
      validator.selfcheck "#{name}.any[#{num++}]", entry

