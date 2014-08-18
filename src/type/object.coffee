# Object validator
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
# Check options:
#
# - `instanceOf` - only objects of given class type are allowed
# - `mandatoryKeys` - the list of elements which are mandatory
# - `allowedKeys` - gives a list of elements which are also allowed
#   or true to use the list from entries definition
#
# Validating children:
#
# - `entries` - specification for entries
exports.check = (source, options, value, work, cb) ->
  # add mandatory keys to allowed keys
  allowedKeys = []
  allowedKeys = allowedKeys.concat options.allowedKeys if options.allowedKeys?
  if options.entries?
    for key in Object.keys options.entries
      allowedKeys.push key unless allowedKeys[key]
  if options.mandatoryKeys?
    for entry in options.mandatoryKeys
      allowedKeys.push entry unless allowedKeys[entry]
  # validate
  if options.instanceOf?
    unless value instanceof options.instanceOf
      return helper.result "An object of #{options.instanceOf.name} is needed
        as value", source, options, null, cb
    return helper.result null, source, options, value, cb
  if typeof value isnt 'object' or value instanceof Array
    return helper.result "The value has to be an object", source, options, null, cb
  if options.allowedKeys? and (options.allowedKeys.length or options.allowedKeys is true)
    for key of value
      unless key in allowedKeys
        return helper.result "The key '#{key}' is not allowed", source, options, null, cb
  if options.mandatoryKeys?
    for key in options.mandatoryKeys
      keys = Object.keys value
      unless key in keys
        opt = options.entries?[key] ? options.entries ? {}
        return helper.result "The key '#{key}' is missing", source, opt, null, cb
  if options.entries?
    if cb?
      # run async
      return async.each Object.keys(value), (key, cb) ->
        suboptions = if options.entries.check?
          options.entries
        else
          options.entries[key]
        return cb() unless suboptions?
        # run subcheck
        helper.check "#{source}.#{key}", suboptions, value[key], work, (err, result) ->
          # check response
          return cb err if err
          value[key] = result
          cb()
      , (err) -> helper.result err, source, options, value, cb
    # run sync
    for key, subvalue of value
      suboptions = if options.entries.check?
        options.entries
      else
        options.entries[key]
      continue unless suboptions?
      # run subcheck
      result = helper.check "#{source}.#{key}", suboptions, subvalue, work
      # check response
      return helper.result result, source, options, null if result instanceof Error
      value[key] = result
  # done return resulting value
  return helper.result null, source, options, value, cb

# Reference check
# -------------------------------------------------
exports.reference = (source, options, value, work, cb) ->
  if options.entries?
    if cb?
      # run async
      return async.each Object.keys(value), (key, cb) ->
        suboptions = if options.entries.check?
          options.entries
        else
          options.entries[key]
        return cb() unless suboptions?
        # run subcheck
        helper.reference "#{source}.#{key}", suboptions, value[key], work, (err, result) ->
          # check response
          return cb err if err
          value[key] = result
          cb()
      , (err) -> helper.result err, source, options, value, cb
    # run sync
    for key, subvalue of value
      suboptions = if options.entries.check?
        options.entries
      else
        options.entries[key]
      continue unless suboptions?
      # run subcheck
      result = helper.reference "#{source}.#{key}", suboptions, subvalue, work
      # check response
      return helper.result result, source, options, null if result instanceof Error
      value[key] = result
  # done return resulting value
  return helper.result null, source, options, value, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  text = 'Here an object have to be given. '
  if options.mandatoryKeys?
    text += "The keys #{options.mandatoryKeys} have to be included. "
  if options.allowedKeys?
    text += "The keys #{options.allowedKeys} are optional. "
  if options.instanceOf?
    text += "The object has to be an instance of #{options.instanceOf}. "
  if options.entries?
    if options.entries.check?
      text += "All entries should be:\n> #{helper.describe options.entries} "
    else
      text += "Entries should contain:\n"
      for entry, num in options.entries
        if options.entries[key]?
          text += "\n- #{key} - #{helper.describe options.entries[key]} "
        else
          text += "\n- #{key} - Free input without specification. "
  text.trim()

