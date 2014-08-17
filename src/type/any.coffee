# Validator to match any of the possibilities
# =================================================

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
  if cb?
    # run async
    return async.map options.entries, (suboptions, cb) ->
      return cb new Error "Undefined" unless suboptions?
      # run subcheck
      helper.check source, suboptions, value, work, (err, result) ->
        return cb null, err if err
        cb null, result
    , (err, results) ->
      # check response
      for result in results
        unless result instanceof Error
          return helper.result null, source, options, result, cb
      helper.result "None of the alternatives are matched", source, options, null, cb
  #run sync
  for suboptions in options.entries
    continue unless suboptions?
    # run subcheck
    result = helper.check source, suboptions, value, work
    # check response
    unless result instanceof Error
      return helper.result null, source, options, result, cb
  # done without success
  helper.result "None of the alternatives are matched", source, options, null, cb

# Reference check
# -------------------------------------------------
exports.reference = (source, options, value, work, cb) ->
  # skip reference check if not defined
  unless options.reference
    return exports.result null, source, options, value, cb
  # check references sync
  unless cb?
    value = reference.check source, options.reference, value, work
    if value instanceof Error
      return exports.result value, source, options, null
    return exports.result null, source, options, value
  # check references async
  reference.check source, options.reference, value, work, (err, value) ->
    exports.result err, source, options, value, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  text = "Here one of the following checks have to succeed:\n"
  for entry in options.entries
    text += "\n- #{helper.describe entry} "
  text += "\n" + reference.describe options.reference if options.reference
  text.trim()

