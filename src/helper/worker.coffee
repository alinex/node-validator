# Check class
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:worker')
chalk = require 'chalk'
async = require 'async'
# alinex packages
util = require 'alinex-util'
# internal classes and helper
#reference = require './reference'


# Worker Class
# -------------------------------------------------
# The worker class collects all data needed to check the validation of structures.

class Worker

  # on demand loaded type libraries
  # `Object` list of loaded type libraries with the following methods:
  # - `init` - called for first initialization (optional)
  # - `describe` - get human readable description
  # - `check` - run the check for these element
  @lib: {}

  # easy call to inspect data structures for debugging
  #
  # @param obj to be inspected
  # @param {Integer} depth the number of times to recurse into object
  # @return {String} one line of inspection
  @inspect: (obj, depth=1) ->
    util.inspect obj,
      depth: depth
      breakLength: Infinity


  # Worker instance
  # ------------------------------------------------------------
  # The worker instance contains all relevant informations for an work step within the
  # complete check run.
  #
  # The following attributes are used:
  # - `name` - `String` descriptive name of the data origin
  # - `schema` - `Object` structure to check
  # - `context` - `Object` additional data structure
  # - `dir` - `String` set to base directory for file relative file paths
  # - `value` - original value (not changed)
  #
  # And the possible methods are:
  # - `debug` - type specific debug output
  # - `check` - run the type specific check
  # - `inspectValue` - get value for debugging output
  # - `inspectSchema` - get schema for debugging output
  # - `sendError` - end check with error
  # - `sendSuccess` - end check with success


  # - failed - internally used to check for references to unchecked parts
  # - done - internally used as list of checked paths
  # - path - array containing the current path
  # - pos - reference to schema position at this path
  # - debug - output of current path for debugging
  # - value - value at this path
  # - vpath - path of value
  # - retry counter for retry to get references checked

  # Initialize the work structure and set some defaults
  #
  # @param {String} name descriptive name of the data origin
  # @param {Object} schema structure to check
  # @param {Object} [context] additional data structure
  # @param {String} dir set to base directory for file relative file paths
  # @param value original value (not changed)
  # @return {Worker} instance
  constructor: (@name, @schema, @context, @dir, @value) ->
    @type = @schema.type
    # load library if not done
    unless Worker.lib[@type]
      try
        Worker.lib[@type] = require "../type/#{@type}"
        debug "loaded #{@type} check library"
      catch error
        throw new Error "Could not load library for '#{@type}': #{error.message}"
    # add lib into this element
    @debug = =>
      fn = Worker.lib[@type].debug ? debug
      fn.apply this, arguments
    # initialize this element
    Worker.lib[@type].init.call this

  # Check the given value against schema.
  #
  # @param {function(Error)} cb callback to be called after checking with possible
  # error
  check: (cb) ->
    @debug "#{@name}: #{@schema.title}" if @schema.title
    @debug chalk.grey "#{@name}: check value #{@inspectValue()} which should be #{@inspectSchema()}"
    Worker.lib[@type].check.call this, cb

  # Inspect the current value with predefined settings.
  #
  # @return {String} one line of description
  inspectValue: =>
    Worker.inspect @value

  # Inspect the element schema with predefined settings.
  #
  # @return {String} one line of description (compressed)
  inspectSchema: =>
    keys = Object.keys(@schema).filter (e) -> e not in ['title', 'description']
    out = {}
    out[k] = @schema[k] for k in keys
    Worker.inspect out

  # End check with error.
  #
  # @param {String} msg error message
  # @param {function(Error)} cb callback
  sendError: (msg, cb) =>
    err = new Error msg
    err.worker = this
    debug chalk.magenta err
    cb err

  # End check with success.
  #
  # @param {function()} cb callback
  sendSuccess: (cb) =>
    @debug chalk.grey "#{@name}: succeeded with #{@inspectValue()}"
    cb()




#
#    @spec.done ?= []      # list of checked paths
#    @path ?= []           # current path in schema structure
#    @pos ?= @spec.schema  # reference to schema at path (root)
#    @vpath ?= []          # current path in value structure
#    @value = @spec.value  # reference to value at path (root)
#    @debug = chalk.grey "#{@spec.name ? 'value'}/#{@path.join '/'}"

  # ### Report an error
  # This method will use the given Error and make it more readable by adding
  # context information. And adding an additional `description` property
  # containing a detailed description of what is allowed at the current
  # position.
  report: (err, cb) ->
    # create title with context info
    message = "#{err.message} in #{@spec.name ? 'value'}:/#{@vpath.join '/'}"
    message += " '#{@pos.title}'" if @pos.title?
    message += " (described in schema:/#{@path.join '/'}). "
    # create description
    detail = ''
    if @pos.description?
      desc = @pos.description[0].toLowerCase() + @pos.description[1..]
      desc = desc.replace /\.\s*$/, ''
      detail = "It should contain #{desc}. \n"
    # add type specific information
    exports.describe this, (err, text) =>
      detail += text
      debug @debug + chalk.magenta " Error: #{message}"
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
      sub.value = util.clone @value
    # end call if no more steps to go into
    return sub unless schema.length or value.length
    # recursively go one step further
    sub.goInto schema, value


# Exported Class
# -------------------------------------------------
module.exports = Worker
