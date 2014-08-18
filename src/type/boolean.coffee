# Boolean value validation
# =================================================
# No options allowed.

# Node modules
# -------------------------------------------------
async = require 'async'
util = require 'util'
# include classes and helper
helper = require '../helper'
reference = require '../reference'

# Sanitize and validate
# -------------------------------------------------
exports.check = (source, options, value, work, cb) ->
  unless value?
    return helper.result null, source, options, false, cb
  switch typeof value
    when 'boolean'
      return helper.result null, source, options, value, cb
    when 'string'
      switch value.toLowerCase()
        when 'true', '1', 'on', 'yes'
          return helper.result null, source, options, true, cb
        when 'false', '0', 'off', 'no'
          return helper.result null, source, options, false, cb
    when 'number'
      switch value
        when 1
          return helper.result null, source, options, true, cb
        when 0
          return helper.result null, source, options, false, cb
    else
      return helper.result "No boolean value given", source, options, null, cb
  helper.result "The value #{value} is no boolean", source, options, null, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  "The value has to be a boolean. The value will be true for 1, 'true', 'on',
  'yes' and it will be considered as false for 0, 'false', 'off', 'no', '.
  Other values are not allowed."

