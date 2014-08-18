# Array validator
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
#
# Sanitize options:
#
# - `delimiter` - allow value text with specified list separator
#   (it can also be an regular expression)
#
# Check options:
#
# - `notEmpty` - set to true if an empty array is not valid
# - `minLength` - minimum number of entries
# - `maxLength` - maximum number of entries
#
# Validating children:
#
# - `èntries` - specification for all entries or as array for each element
exports.check = (source, options, value, work, cb) ->
  # sanitize
  if typeof value is 'string' and options.delimiter?
    value = value.split options.delimiter
  # validate
  unless Array.isArray value
    return helper.result "The value has to be an array", source, options, null, cb
  if options.notEmpty and value.length is 0
    return helper.result "An empty array/list is not allowed", source, options, null, cb
  if options.minLength? and options.minLength is options.maxLength and (
    value.length isnt options.minLength)
    return helper.result "Exactly #{options.minLength} entries are required
      ", source, options, null, cb
  else if options.minLength? and options.minLength > value.length
    return helper.result "At least #{options.minLength} entries are required
      in list ", source, options, null, cb
  else if options.maxLength? and options.maxLength < value.length
    return helper.result "Not more than #{options.maxLength} entries are allowed in list
      ", source, options, null, cb
  if options.entries? and value.length
    if cb?
      # run async
      return async.each [0..value.length-1], (i, cb) ->
        suboptions = if Array.isArray options.entries
          options.entries[i]
        else
          options.entries
        return cb() unless suboptions?
        # run subcheck
        helper.check "#{source}.#{i}", suboptions, value[i], work, (err, result) ->
          # check response
          return cb err if err
          value[i] = result
          cb()
      , (err) ->
        cb err, value
    #run sync
    for subvalue, i in value
      suboptions = if Array.isArray options.entries
        options.entries[i]
      else
        options.entries
      continue unless suboptions?
      # run subcheck
      result = helper.check "#{source}.#{i}", suboptions, subvalue, work
      # check response
      return result if result instanceof Error
      value[i] = result
  # done return resulting value
  return helper.result null, source, options, value, cb


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
  text = 'Here a list have to be given. '
  if options.notEmpty
    text += "It's not allowed to be empty. "
  if options.delimiter?
    text += "You may also give a single text using '#{options.delimiter}' as
      for the individual entries. "
  if options.minLength? and options.maxLength?
    text += "The number of entries have to be between #{options.minLength}
      and #{options.maxLength}. "
  else if options.minLength?
    text += "At least #{options.minLength} elements should be given. "
  else if options.maxLength?
    text += "Not more than #{options.maxLength} elements are allowed. "
  if options.entries?
    if Array.isArray options.entries
      text += "Entries should contain:\n"
      for entry, num in options.entries
        if options.entries[num]
          text += "\n#{num}. #{helper.describe options.entries[num]} "
        else
          text += "\n#{num}. Free input without specification. "
    else
      text += "All entries should be:\n> #{helper.describe options.entries} "
  text.trim()

