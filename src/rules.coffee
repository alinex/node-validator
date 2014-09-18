# Base validation rules
# =================================================
# This is a collection of general check rules which are not specific to any type.

# Node modules
# -------------------------------------------------
async = require 'async'
util = require 'util'
# include classes and helper

module.exports = rules =

  # Description
  # -------------------------------------------------
  describe:

    optional: (options) ->
      value = options.default ? null
      "This is optional and may not be set. If let blank it will be set to
      #{value}. "

  # Synchronous checks
  # -------------------------------------------------
  sync:

    # ### optional, default
    optional: (check, path, options, value) ->
      # check for value
      unless isEmpty value
        return value
      # check for optional
      unless options.optional or options.default
        throw check.error path, options, value,
        new Error "A value is needed"
      # send default back
      options.default ? null

  # Selfcheck definition
  # -------------------------------------------------
  selfcheck:

    # ### detect references
    reference:
      type: 'object'
      entries:
        reference:
          type: 'string'
        source:
          type: 'string'
        operation:
          type: 'function'


# helper methods
# -------------------------------------------------

# ### Is value empty?
isEmpty = (value) ->
  return true unless value?
  switch typeof value
    when 'object'
      if value.constructor.name is 'Object' and Object.keys(value).length is 0
        return true
    when 'array'
      if value.length is 0
        return true
  false

