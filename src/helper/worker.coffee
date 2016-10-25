# Check class
# =================================================

# Node modules
# -------------------------------------------------
Debug = require 'debug'
debug = Debug 'validator:worker'
chalk = require 'chalk'
async = require 'async'
# alinex packages
util = require 'alinex-util'
# internal classes and helper
reference = require './reference'


# Worker Class
# -------------------------------------------------
# The worker class collects all data needed to check the validation of structures.

class Worker

  # On demand loaded type libraries
  # `Object` list of loaded type libraries with the following methods:
  # - `init` - called for first initialization (optional)
  # - `describe` - get human readable description
  # - `check` - run the check for these element
  @lib: {}

  # Easy call to inspect data structures for debugging
  #
  # @param obj to be inspected
  # @param {Integer} depth the number of times to recurse into object
  # @return {String} one line of inspection
  @inspectObject: (obj, depth=1) ->
    util.inspect obj,
      depth: depth
      breakLength: Infinity
    .replace /\s*\n\s*/g, ' '

  # Load type specific library
  #
  # @param {String} type of the library to load
  # @name {String} name of value origin for error messages
  # @return {Object<Function>} library for given type
  @load: (type, name) ->
    # load library if not done
    unless Worker.lib[type]
      try
        Worker.lib[type] = require "../type/#{type}"
        Worker.lib[type].debug = Debug "validator:#{type}"
        debug "loaded #{type} check library" if debug.enabled
      catch error
        debug chalk.magenta error.message if debug.enabled
        throw new Error "Could not load library for '#{type}' type at #{name}"
    Worker.lib[type]


  # Worker instance
  # ------------------------------------------------------------
  # The worker instance contains all relevant informations for an work step within the
  # complete check run.
  #
  # The following attributes are used:
  # - `name` - `String` descriptive name of the data origin
  # - `schema` - `Object` structure to check
  # - `context` - `Object` additional data structure
  # - `value` - original value (not changed)
  # - `root` - the root worker of this check
  # - `path` - the current path in value structure
  #
  # And only in the root worker:
  # - `checked` - list of already checked elements (used for references)
  # - 'allowData' - `Boolean` references to data:// only allowed in schema to value
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
  # @param value original value (not changed)
  # @return {Worker} instance
  constructor: (@name, @schema, @context, @value, @root = this) ->
    @type = @schema.type
    @lib = Worker.load @type, @name
    @debug = @lib.debug
    @path = @name.replace /#[^.]*/g, ''
    .split(/\./)[1..].join '/'
    @root.checked ?= []
    # initialize this element
    fn.call this if fn = @lib.init


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
    # add title and description
    text = ''
    if @schema.title
      text += "__#{@schema.title}__ "
      sp = if @schema.title[-1..] is 's' and @schema.title[-2..] isnt 'ss' then 'are' else 'is'
      text += "#{sp} #{@schema.description}." if @schema.description
      text += "\n\n"
    # add details
    @lib.describe.call this, (err, detail) ->
      return cb err if err
      cb null, text + detail

  # Check the given value against schema.
  #
  # @param {function(Error)} cb callback to be called after checking with possible
  # error
  check: (cb) ->
    if @debug.enabled
      @debug "#{@name}: #{@schema.title}" if @schema.title
      @debug chalk.grey "#{@name}: resolve possible references"
    async.parallel [
      # dereference value
      (cb) =>
        reference.replace @value, this, (err, value) =>
          return cb err if err
          @value = value
          cb()
      # dereference schema
      (cb) =>
        reference.replaceSchema @schema, this, (err, value) =>
          return cb err if err
          @schema = value
          cb()
      # validate values
      (cb) =>
        reference.existsWait this, (err) =>
          return cb err if err
          reference.existsSchemaWait this, (err) =>
            return cb err if err
            @debug chalk.grey "#{@name}: check value #{@inspectValue()} which should be
            #{@inspectSchema()}"
            @lib.check.call this, (err) =>
              return cb err if err
              @root.checked.push @path
              cb()
    ], cb

  # Create a sub worker instance.
  #
  # @param {String} name descriptive name of the data origin
  # @param {Object} schema structure to check
  # @param value original value
  # @return {Worker} instance
  sub: (name, schema, value) ->
    new Worker name, schema, @context, value, this


  # Type Helper Methods
  # -------------------------------------------------

  # Inspect the current value with predefined settings.
  #
  # @return {String} one line of description
  inspectValue: =>
    Worker.inspectObject @value

  # Inspect the element schema with predefined settings.
  #
  # @return {String} one line of description (compressed)
  inspectSchema: =>
    keys = Object.keys(@schema).filter (e) -> e not in ['title', 'description']
    out = {}
    out[k] = @schema[k] for k in keys
    Worker.inspectObject out

  # End check with error.
  #
  # @param {String} msg error message
  # @param {function(Error)} cb callback
  sendError: (msg, cb) =>
    err = new Error "#{msg} at validation of #{@name}"
    err.worker = this
    if @debug.enabled
      @debug chalk.magenta msg
      @debug chalk.grey "  validation of #{@name}"
      @debug chalk.grey "  value: #{@inspectValue.call this}"
      @debug chalk.grey "  schema: #{@inspectSchema.call this}"
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
