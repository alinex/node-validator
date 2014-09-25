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
      if options.class?
        type = if options.class then 'class' else 'function'
        text = "A #{type} reference. "
      else
        "The value has to be a function/class. "
      text += rules.describe.optional options

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
      unless typeof value is 'function'
        throw check.error path, options, value,
        new Error "No function given as value"
      if options.class?
        isClass = value.constructor? and typeof value.constructor is 'function'
        if options.class and not isClass
          throw check.error path, options, value,
          new Error "No class given as value"
        if not options.class and isClass
          throw check.error path, options, value,
          new Error "No function given as value"
      value


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
          type: 'function'
          optional: true
        class:
          type: 'boolean'
          optional: true
    , options
