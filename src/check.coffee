# Check class
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:check')
util = require 'util'
async = require 'alinex-async'
chalk = require 'chalk'
# internal classes and helper
reference = require './reference'

# Work management
# -------------------------------------------------
# The work class contains all relevant informations for an work step within the
# complete check run.
#
# The following properties are used:
#
# - spec - reference to the original validation call
#   - name - (string) descriptive name of the data
#   - schema - (object) structure to check
#   - context - (object) additional data structure
#   - dir - set to base directory for file relative file paths
#   - value - original value (not changed)
# - path - array containing the current path
# - pos - reference to schema position at this path
# - debug - output of current path for debugging
# - value - value at this path

class Work

  constructor: (@spec) ->
    @init()

  init: ->
    # optimize work
    @path ?= []
    @pos ?= @spec.schema
    @value = @spec.value
    @debug = chalk.grey "#{@spec.name ? 'value'}/#{@path.join '/'}"

  report: (err, cb) ->
    message = "#{err.message} in #{@spec.name ? 'value'}/#{@path.join '/'}"
    message += " '#{@pos.title}'" if @pos.title?
    message += '. '
    detail = ''
    if @pos.description?
      desc = @pos.description[0].toLowerCase() + @pos.description[1..]
      desc = desc.replace /\.\s*$/, ''
      detail = "It should contain #{desc}. \n"
    detail +=
    exports.describe @, (err, text) ->
      detail += text
      err = new Error message
      err.description = detail if detail
      cb err

  goInto: (names...) ->
    name = names.shift()
#    console.log name, '>>>', @
    sub = new Work @spec
    sub.path = @path.concat name
    sub.pos = if @pos[name]? then  @pos[name] else @pos
    sub.value = @value
    sub.debug = chalk.grey "#{sub.spec.name ? 'value'}/#{sub.path.join '/'}"
    #console.log name, sub
#    console.log name, '<<<', sub
    return sub unless names.length
    sub.goInto names...

# Helper methods
# -------------------------------------------------

# ### Get type library
# Dynamically loading of type check.
getTypeLib = (type) ->
  # check type
  unless typeof type?.type  is 'string'
    throw new Error "No type given to load"
  type = type.type unless typeof type is 'string'
  # try to load
  require "./type/#{type}"

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

# Main routines
# -------------------------------------------------
# ### Get description of schema
# This may be called using the spec or an already created work instance.
exports.describe = (work, cb) ->
  work = new Work work unless work instanceof Work
  # load library and call check
  lib = getTypeLib work.pos, (err, lib) ->
  unless lib.describe?
    throw new Error "Type '#{work.pos.type}' has no describe() method"
  lib.describe work, cb

# ### Run check
# This may be called using the spec or an already created work instance.
exports.run = (work, cb) ->
  work = new Work work unless work instanceof Work
#  console.log 'check:', work
  # check for references in values
  reference.check work.value,
    spec: work.spec
    path: work.path[0..]    # clone because it may change
  , (err, value) ->
    return work.report err, cb if err
    work.value = value
    # load library and call check
    try
      lib = getTypeLib work.pos, (err, lib) ->
      unless lib.run?
        return cb new Error "Type '#{work.pos.type}' has no run() method"
    catch err
      debug chalk.red "Failed to load '#{work.pos.type}' lib because of: #{err}"
      return cb new Error "Type '#{work.pos.type}' not supported"
    lib.run work, cb

# ### Selfcheck of schema
# This may be called using the spec or an already created work instance.
exports.selfcheck = (schema, cb) ->
  debug "check schema #{util.inspect schema}"
  # load library and call check
  try
    lib = getTypeLib schema, (err, lib) ->
    unless lib.selfcheck?
      return cb new Error "Type '#{schema.type}' has no selfcheck() method"
  catch err
    return cb new Error "Type '#{schema.type}' not supported"
  lib.selfcheck schema, cb

# General checks
# -------------------------------------------------
# ### Optional and default checks
exports.optional =
  describe: (work) ->
    unless work.pos.optional or work.pos.default?
      return ''
    if work.pos.default
      value = if work.pos.default instanceof Function
        '[function]'
      else
        util.inspect work.pos.default
      return "It's optional and will be set to #{value}
      if not specified. "
    else
      return "It's optional."
  run: (work) ->
    # check for value
    return false unless isEmpty work.value # go on if value given
    if work.pos.default? # use default and go on
      work.value = work.pos.default
      return false
    return true if work.pos.optional # end this test without value
    throw new Error "A value is needed"

exports.base =
  title:
    type: 'string'
    optional: true
  description:
    type: 'string'
    optional: true
  key:
    type: 'regexp'
    optional: true
  type:
    type: 'string'
  optional:
    type: 'boolean'
    optional: true
