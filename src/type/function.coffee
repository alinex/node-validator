# Function validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:function')
util = require 'util'
# include classes and helper
rules = require '../rules'


module.exports =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      # combine into message
      "The value has to be a function."

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}", util.inspect(options).grey
      # sanitize
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # value check
      return value if typeof value is 'function'
      # failed
      throw check.error path, options, value,
      new Error "No function given as value"


  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
      type: 'object'
      mandatoryKeys: ['type']
      allowedKeys: true
      entries:
        optional:
          type: 'boolean'
        default:
          type: 'function'
    , options
