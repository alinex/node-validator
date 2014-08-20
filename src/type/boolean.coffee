# Boolean value validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:boolean')
async = require 'async'
util = require 'util'
# include classes and helper
rules = require '../rules'

valuesTrue = ['true', '1', 'on', 'yes', 1, true]
valuesFalse = ['false', '0', 'off', 'no', 0, false]

module.exports =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      # optimize options
      if options.optional and not options.default?
        options.default = false
      # get possible values
      vTrue = valuesTrue.map(util.inspect).join ', '
      vFalse = valuesFalse.map(util.inspect).join ', '
      # combine into message
      "The value has to be a boolean. The value will be true for #{vTrue} and it
      will be considered as false for #{vFalse}. #{rules.describe.optional options}
      Other values are not allowed."

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{path}", util.inspect(options).grey
      # optimize options
      if options.optional and not options.default?
        options.default = false
      # optional check
      value = rules.sync.optional check, path, options, value
      # sanitize
      if typeof value is 'string'
        value = value.toLowerCase()
      # boolean values check
      return true if value in valuesTrue
      return false if value in valuesFalse
      # failed
      throw check.error path, options, value,
      new Error "No boolean value given"
