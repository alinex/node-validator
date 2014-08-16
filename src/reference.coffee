# Validator for references
# =================================================
# This validator is special because it should only run after the normal sanitize
# checks are done in a second run. It will check the referencing between different
# values and maybe different configurations.

debug = require('debug')('validator:reference')
util = require 'util'
# include classes and helper
validator = require './index'
helper = require './helper'


# check this value against another one in this structure
# check this value against another value in a specific configuration

# check:
# - equal: field
# - greater: field
# - lower: field
# - in: field
#
# sanitize:
# - copyFrom: field

valueByName = (name, work) ->
  name

# Greater than
# -------------------------------------------------
exports.check = (source, value, options, work, cb) ->
  debug "Check references for #{source}", util.inspect(options).grey
  # sanitize
  # validate
  if options.greater?
    ref = valueByName options.greater, work
    if value <= ref
      return helper.result "The value '#{value}' in #{source} has to be greater
      than '#{ref}' in #{options.greater}.", source, options, null, cb
  # done return resulting value
  return helper.result null, source, options, value, cb

exports.describe = (options = {}) ->
  text = ''
  if options.greater?
    text = "The value has to be greater than the value in #{options.greater}. "
  text.trim()
