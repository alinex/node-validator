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
      text = "Here one of the following checks have to succeed:\n"
      for entry in options.entries
        text += "\n- #{ValidatorCheck.describe entry} "
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}", util.inspect(options).grey
      # validate
      for suboptions in options.entries
        continue unless suboptions?
        # run subcheck
        try
          return check.subcall path, suboptions, value
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
      async.map options.entries, (suboptions, cb) ->
        # run subcheck
        check.subcall path, suboptions, value, (err, result) ->
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
      validator.selfcheck "#{name}.any[#{num++}]", entry

