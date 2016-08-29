# Check class
# =================================================

# Node modules
# -------------------------------------------------
Debug = require 'debug'
debug = Debug 'validator:worker'
chalk = require 'chalk'
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
    .replace /\s*\n\s*/g, ' '


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
  # - `check` - run the type specific check
  # - `inspectValue` - get value for debugging output
  # - `inspectSchema` - get schema for debugging output
  # - `sendError` - end check with error
  # - `sendSuccess` - end check with success

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
        Worker.lib[@type].debug = Debug "validator:#{@type}"
        debug "loaded #{@type} check library"
      catch error
        throw new Error "Could not load library for '#{@type}': #{error.message}"
    # add lib into this element
    @debug = Worker.lib[@type].debug
    # initialize this element
    fn.call this if fn = Worker.lib[@type].init


  # Main Instance Methods
  # -------------------------------------------------

  # Describe the schema definition.
  #
  # @param {function(Error)} cb callback to be called after checking with possible
  # error
  describe: (cb) ->
    if @debug.enabled
      @debug "#{@name}: #{@schema.title}" if @schema.title
      @debug chalk.grey "#{@name}: describe schema #{@inspectSchema()}"
    Worker.lib[@type].describe.call this, cb

  # Check the given value against schema.
  #
  # @param {function(Error)} cb callback to be called after checking with possible
  # error
  check: (cb) ->
    if @debug.enabled
      @debug "#{@name}: #{@schema.title}" if @schema.title
      @debug chalk.grey "#{@name}: check value #{@inspectValue()} which should be
      #{@inspectSchema()}"
    Worker.lib[@type].check.call this, cb


  # Type Helper Methods
  # -------------------------------------------------

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
    @debug chalk.magenta err
    cb err

  # End check with success.
  #
  # @param {function()} cb callback
  sendSuccess: (cb) =>
    if @debug.enabled
      @debug chalk.grey "#{@name}: succeeded with #{@inspectValue()}"
    cb()


# Exported Class
# -------------------------------------------------
module.exports = Worker
