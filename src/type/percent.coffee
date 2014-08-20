# Percent check
# =================================================

# Sanitize options allowed:
#
# - `unit` - (string) type of unit to convert if not integer given
# - `round` - (bool) rounding can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
# - `decimals` - (int) number of decimal digits to round to (defaults to 2)
#
# Check options:
#
# - `min` - (integer) the smalles allowed number
# - `max` - (integer) the biggest allowed number

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:percent')
async = require 'async'
util = require 'util'
# include classes and helper
rules = require '../rules'
float = require './float'

module.exports = integer =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      options = optimize options
      # combine into message
      text = 'This should be a percentage value which may be given as decimal 0..1
      or as percent value like 30%. '
      text += rules.describe.optional options
      text += float.describe.round options
      text += float.describe.minmax options
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{path}", util.inspect(options).grey
      options = optimize options
      # sanitize
      value = rules.sync.optional check, path, options, value
      if typeof value is 'string' and value.trim().slice(-1) is '%'
        value = value[0..-2]
        unless not isNaN(parseFloat value) and isFinite value
          throw check.error path, options, value,
          new Error "The given value '#{value}' is no number as needed"
        value = value / 100
      return value unless value?
      value = float.sync.round check, path, options, value
      # validate
      value = float.sync.number check, path, options, value
      value = float.sync.minmax check, path, options, value
      # done return resulting value
      value

# Optimize options setting
# -------------------------------------------------
optimize = (options) ->
  if options.decimals and not options.round?
    options.round = true
  if options.round and not options.decimals?
    options.decimals = 2
  options
