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
#   - failed - internally used to check for references to unchecked parts
#   - done - internally used as list of checked paths
# - path - array containing the current path
# - pos - reference to schema position at this path
# - debug - output of current path for debugging
# - value - value at this path
# - vpath - path of value
# - retry counter for retry to get references checked

class Work

  # ### Create a new work instance
  # Initialize the work structure and set some defaults.
  constructor: (@spec) ->
    @spec.done ?= []      # list of checked paths
    @path ?= []           # current path in schema structure
    @pos ?= @spec.schema  # reference to schema at path (root)
    @vpath ?= []          # current path in value structure
    @value = @spec.value  # reference to value at path (root)
    @debug = chalk.grey "#{@spec.name ? 'value'}/#{@path.join '/'}"

  # ### Report an error
  # This method will use the given Error and make it more readable by adding
  # context information. And adding an additional `description` property
  # containing a detailed description of what is allowed at the current
  # position.
  report: (err, cb) ->
    # create title with context info
    message = "#{err.message} in #{@spec.name ? 'value'}/#{@vpath.join '/'}"
    message += " '#{@pos.title}'" if @pos.title?
    message += " (described in /#{@path.join '/'}). "
    # create description
    detail = ''
    if @pos.description?
      desc = @pos.description[0].toLowerCase() + @pos.description[1..]
      desc = desc.replace /\.\s*$/, ''
      detail = "It should contain #{desc}. \n"
    # add type specific information
    exports.describe this, (err, text) =>
      detail += text
      # create new Error object
      err = new Error message
      err.description = detail if detail
      err.path = @vpath.join '/'
      # send error through callback
      cb err

  # ### Go into
  # Get a new work object representing the inner position of the current work
  # object. The position may change in the schema and/or value position.
  # This makes the new object containing the information at the old path
  # concatenated with the given paths.
  goInto: (schema = [], value = []) ->
    # create new instance
    sub = new Work @spec
    if schema.length
      # go one step into schema structure
      name = schema.shift()
      sub.path = @path.concat name
      sub.pos = if @pos[name]? then  @pos[name] else @pos
      sub.debug = chalk.grey "#{sub.spec.name ? 'value'}/#{sub.path.join '/'}"
    else
      # keep schema position but clone path
      sub.path = @path[0..]
      sub.pos = @pos
      sub.debug = @debug
    if value.length
      # go one step into value structure
      v = value.shift()
      sub.vpath = @vpath.concat v
      sub.value = if @value[v]? then  @value[v] else undefined
    else
      # keep value position but clone path
      sub.vpath = @vpath[0..]
      sub.value = @value
    # end call if no more steps to go into
    return sub unless schema.length or value.length
    # recursively go one step further
    sub.goInto schema, value

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
  switch
#    when Array.isArray value
#      if value.length is 0
#        return true
    when typeof value is 'object'
      if value.constructor.name is 'Object' and Object.keys(value).length is 0
        return true
  false

# Main routines
# -------------------------------------------------

# ### Get description of schema
# This may be called using the spec or an already created work instance.
exports.describe = (work, cb) ->
  work = new Work work unless work instanceof Work
  # load library
  try
    lib = getTypeLib work.pos
    unless lib.describe?
      throw new Error "Type '#{work.pos.type}' has no describe() method"
  catch err
    debug chalk.red "Failed to load '#{work.pos.type}' lib because of: #{err}"
    return cb new Error "Type '#{work.pos.type}' not supported"
  # call description on that library
  lib.describe work, cb

# ### Run check
# This may be called using the spec or an already created work instance.
exports.run = (work, cb) ->
  work = new Work work unless work instanceof Work
  debug "#{work.debug} checking..."
  # check for references in schema
  async.mapOf work.pos, (v, k, cb) ->
    reference.replace v,
      spec: work.spec
      path: work.path[0..]    # clone because it may change
    , cb
  , (err, result) ->
    return work.report err, cb if err
    work.pos = result
    # check for references in values
    reference.replace work.value,
      spec: work.spec
      path: work.path[0..]    # clone because it may change
    , (err, value) ->
      return work.report err, cb if err
      # store result also in spec for references to use
      obj = work.spec.value
      for n in work.vpath
        obj = obj?[n]
      obj = value if obj?
      # and set as done
      work.spec.done.push work.vpath.join '/'
      work.value = value
      # load library
      try
        lib = getTypeLib work.pos
        unless lib.run?
          return cb new Error "Type '#{work.pos.type}' has no run() method"
      catch err
        debug chalk.red "Failed to load '#{work.pos.type}' lib because of: #{err}"
        return cb new Error "Type '#{work.pos.type}' not supported"
      # and call library to run the real check
      lib.run work, cb

# ### Selfcheck of schema
# This may be called using the spec or an already created work instance.
exports.selfcheck = (schema, cb) ->
  debug "check schema #{util.inspect schema}"
  # load library and call check
  try
    lib = getTypeLib schema
    unless lib.selfcheck?
      return cb new Error "Type '#{schema.type}' has no selfcheck() method"
  catch err
    return cb new Error "Type '#{schema.type}' not supported"
  # run the selfcheck
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

# ### selfcheck schema for base options
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
