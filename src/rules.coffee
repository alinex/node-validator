# Base validation rules
# =================================================
# This is a collection of general check rules which are not specific to any type.

# Node modules
# -------------------------------------------------
async = require 'alinex-async'
util = require 'util'
# include classes and helper

module.exports = rules =

  # Description
  # -------------------------------------------------
  describe:

    optional: (options) ->
      value = switch
        when typeof options.default is 'function' and options.default.name
          options.default.name
        when options.default?
          util.inspect options.default
        else
          null
      "It's optional and will be set to #{value} if not specified. "

  # Synchronous checks
  # -------------------------------------------------
  sync:

    # ### optional, default
    optional: (check, path, options, value) ->
      # check for value
      unless isEmpty value
        return value
      # check for optional
      unless options.optional or options.default?
        throw check.error path, options, value,
        new Error "A value is needed"
      # send default back
      options.default ? null

    reference: (check, path, options, value) ->
      hasErr = false
      for key of value
        try
          if Array.isArray value[key]
            value[key] = check.subcall path.concat(key), null, value[key]
          else if typeof value[key] is 'object'
            value[key] = check.subcall path.concat(key), null, value[key]
          else
            value[key] = check.subcall path.concat(key), null, value[key]
        catch err
          if err.message is 'EAGAIN'
            hasErr = err
          else
            throw err
      throw hasErr if hasErr
      value

  # Selfcheck definition
  # -------------------------------------------------
  selfcheck:

    # ### detect references
    reference:
      type: 'object'
      entries:
        reference:
          type: 'string'
          values: ['absolute', 'relative', 'external']
        source:
          type: 'string'
        operation:
          type: 'function'
          optional: true


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

