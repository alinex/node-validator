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



exports.valueByName = (source, name, work) ->
  # calculate the path
  if name[0] is '#'
    path = "data.#{name[1..]}"
  else if name[0] is '@'
    name = name[1..]
    path = source.split '.'
    first = path.shift()
    while name[0] is '<'
      path.shift()
      name = name[1..]
    path.push name
    name = "#{first}.#{path.join '.'}"
    path = "self.#{path.join '.'}"
  else
    path = "self.#{name}"
    first = source.split('.')[0]
    name = "#{first}.#{name}"
#  console.log path, work
  obj = work
  for part in path.split '.'
    unless obj[part]?
      debug "reference #{name} not found"
      return null
    obj = obj[part]
  [name, obj]

# Greater than
# -------------------------------------------------
exports.check = (source, options, value, work, cb) ->
  debug "Check references for #{source}", util.inspect(options.reference).grey
  # sanitize
  # validate
  if options.reference.greater?
    [refname, refvalue] = exports.valueByName source, options.reference.greater, work
    if refvalue? and value <= refvalue
      return helper.result "The value '#{value}' in #{source} has to be greater
      than '#{refvalue}'", refname, options, null, cb
  # done return resulting value
  return helper.result null, source, options, value, cb

exports.describe = (options = {}) ->
  text = ''
  if options.greater?
    text = "The value has to be greater than the value in #{options.greater}. "
  text.trim()
