# Check class
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator')
util = require 'util'
async = require 'alinex-async'
chalk = require 'chalk'
# internal classes and helper


# Class for validation
# -------------------------------------------------
# ### Instance properties
#
# - source - original name of source
# - options - check definition
# - value - check value
# - data - additional references for checks
# - runAgain - true for another check round
# - checked - list of paths which are checked
#
class ValidatorCheck

  # ### Get description for check
  @describe: (options) ->
    getTypeLib(options).describe.type(options).trim()

  # ### New run needed?
  # If this is true a new sync or async run is needed. This may lead to multiple
  # runs in case of references to references...
  runAgain: true

  # ### Initialize data for check
  constructor: (@source, @options, @value, @data) ->
    @checked = []
#    for key in Object.keys @options
#      @options[key] = @ref2value [''], @options[key], key

  # ### Pathname to be printed
  pathname: (path) ->
    if path? and path.length
      return chalk.grey "#{@source}.#{path.join '.'}"
    chalk.grey @source

  # ### Create error message
  # This is called by the subclasses
  error: (path, options, value, err) ->
    unless options
      throw new Error "Validator called without options."
    message = "#{err.message} in #{@pathname path}"
    if options.title?
      message += " '#{options.title}'"
    message += '. '
    detail = []
    if options.description?
      detail = "It should contain #{options.description}. \n"
    detail += ValidatorCheck.describe options
    err = new Error message
    err.description = detail if detail
    err

  # ### Synchronous check
  sync: ->
    debug "#{@pathname()} start sync check as #{@options.type}"
    lib = getTypeLib @options
    unless lib.sync?.type?
      return new Error "Could not synchronously call #{@options.type} check in '#{@pathname()}'"
    try
      result = @value
      num = 0
      while @runAgain
        @runAgain = false
        debug "#{@pathname()} round ##{++num}"
        result = lib.sync.type @, [], @options, result
      debug "#{@pathname()} success: #{util.inspect(result).replace /\n/g, ''}"
      result
    catch err
      debug "#{@pathname()} failed with #{err}"
      throw err

  # ### Asynchronous check
  async: (cb) ->
    debug "#{@pathname()} start async check as #{@options.type}"
    lib = getTypeLib @options
    # call async lib
    if lib.async?.type?
      result = @value
      num = 0
      return async.whilst =>
        @runAgain is true
      , (cb) =>
        @runAgain = false
        debug "#{@pathname()} round ##{++num}"
        lib.async.type @, [], @options, result, (err, res) ->
          result = res
          cb err, res
      , (err) =>
        if err
          debug "#{@pathname()} failed with #{err}"
          return cb err
        debug "#{@pathname()} success: #{util.inspect(result).replace /\n/g, ''}"
        cb null, result
    # alternatively run sync code
    try
      result = @value
      while @runAgain
        @runAgain = false
        result = lib.sync.type @, [], @options, result
      debug "#{@pathname()} success: #{util.inspect(result).replace /\n/g, ''}"
      cb null, result
    catch err
      debug "#{@pathname()} failed with #{err}"
      cb err

  # ### optional, default
  reference: (path, options = { type: 'reference' }, value) ->
    return value if 'REF' in path # no checking within the reference declaration itself
    debug "#{@pathname path} check as #{options.type}"
    lib = getTypeLib options
    lib.sync.type @, path, options, value

  subcall: (path, options, value, cb) ->
    # check for references
    try
      # check for references in value and options
      value = @reference path, null, value
#      for key in Object.keys options
#        options[key] = @reference path, null, options[key]
      # set field as checked
      pathname = path.join '.'
      @checked.push pathname unless pathname in @checked
    catch err
      if err.message is 'EAGAIN'
        debug "#{@pathname path} run again because reference not ready"
        @runAgain = true
        return value unless cb?
        return cb null, value
      throw err unless cb?
      return cb err
    finally
      unless options
        debug "#{@pathname path} finished", chalk.grey util.inspect value
        return value unless cb?
        return cb null, value
      debug "#{@pathname path} check as #{options.type}"
      lib = getTypeLib options
      unless cb?
        # sync call sync
        unless lib.sync?.type?
          return new Error "Could not synchronously call #{options.type} check in
          #{@pathname path}."
        result = lib.sync.type @, path, options, value
        debug "#{@pathname path} finished", chalk.grey util.inspect result
        return result
      else
        # async call async
        if lib.async?.type?
          return lib.async.type @, path, options, value, (err, result) ->
            unless err
              debug "#{@pathname path} finished", chalk.grey util.inspect result
            cb err, result
        # async call sync
        try
          result = lib.sync.type @, path, options, value
        catch err
          return cb err
        cb null, result

# Export the class
module.exports = ValidatorCheck


# Helper methods
# -------------------------------------------------

# ### Get type library
getTypeLib = (name) ->
  if typeof name is 'string'
    return require "./type/#{name}"
  if name.type?
    return require "./type/#{name.type}"
  throw Error "Undefined validator type #{name}"
