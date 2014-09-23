# Validator to match multiple definitions
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:and')
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
      text = "Here all of the following checks have to succeed:\n"
      for entry in options.entries
        text += "\n- #{ValidatorCheck.describe entry} "
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
      try
        for suboptions in options.entries
          continue unless suboptions?
          # run subcheck
          value = check.subcall path.concat(num++), suboptions, value
      catch err
        # error, not all matched
        throw check.error path, options, value,
        new Error "Not all of the rules matched"
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
      catch err
        return cb err
      # run async checks
      num = 0
      async.eachSeries options.entries, (suboptions, cb) ->
        # run subcheck
        check.subcall path, suboptions, value, (err, result) ->
          # check response
          return cb err if err
          value = result
          cb()
      , (err) ->
        # check response
        if err
          return cb check.error path.concat(num++), options, value,
          new Error "Not all of the rules matched"
        cb null, value


  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
      type: 'object'
      mandatoryKeys: ['type']
      allowedKeys: true
      entries:
        title:
          type: 'string'
        description:
          type: 'string'
        entries:
          type: 'array'
          entries:
            type: 'object'
    , options
    # Check type specific
    num = 0
    for entry in options.entries
      validator.selfcheck "#{name}.all[#{num++}]", entry

