# Check class
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator')
util = require 'util'
async = require 'alinex-async'
chalk = require 'chalk'
# internal classes and helper

# Configuration
# -------------------------------------------------
# the maximum number of runs to try to solve references
MAXRUNS = 10

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

###################### TODO ###############################
# resolve references in direct option settings
#    for key in Object.keys @options
#      @options[key] = @ref2value [''], @options[key], key
###################### TODO ###############################

  # ### Pathname to be printed
  # give color = false as parameter for error messages
  pathname: (path, color = true) ->
    msg = @source
    if path? and path.length
      msg = "#{@source}.#{path.join '.'}"
    return msg unless color
    chalk.grey msg

  # ### Create error message
  # This is called by the subclasses
  error: (path, options, value, err) ->
    unless options
      throw new Error "Validator called without options."
    message = "#{err.message} in #{@pathname path, false}"
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
        if @runAgain and num >= MAXRUNS
          throw new Error 'Stopped validation because of endless loop in references'
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
        lib.async.type @, [], @options, result, (err, res) =>
          if @runAgain and num >= MAXRUNS
            return cb new Error 'Stopped validation because of endless loop in references'
          cb err, res
      , (err) =>
        if err
          debug "#{@pathname()} failed with #{err}"
          return cb err
        debug "#{@pathname()} success: #{util.inspect(result).replace /\n/g, ''}"
        cb null, result
    # alternatively run sync code
    try
      num = 0
      result = @value
      while @runAgain
        @runAgain = false
        debug "#{@pathname()} round ##{++num}"
        result = lib.sync.type @, [], @options, result
        if @runAgain and num >= MAXRUNS
          return cb new Error 'Stopped validation because of endless loop in references'
      debug "#{@pathname()} success: #{util.inspect(result).replace /\n/g, ''}"
      cb null, result
    catch err
      debug "#{@pathname()} failed with #{err}"
      cb err

  # ### check reference
  # This short helper will load the reference check and execute it.
  reference: (path, options = { type: 'reference' }, value) ->
    return value if 'REF' in path # no checking within the reference declaration itself
    debug "#{@pathname path} check as #{options.type}"
    lib = getTypeLib options
    lib.sync.type @, path, options, value

  # ### Subcheck
  subcall: (path, options, value, cb) ->
    # return if already checked value
    pathname = path.join '.'
    if pathname in @checked
      return value unless cb?
      return cb null, value
    # check for references
    failed = false
    try
      # check for references in value and options
      value = @reference path, null, value

############# TODO ####################################
#      for key in Object.keys options
#        options[key] = @reference path, null, options[key]
############# TODO ####################################

    catch err
      if err.message is 'EAGAIN'
        # if the references could not be checked keep reference an use another round
        debug "#{@pathname path} run again because reference not ready"
        @runAgain = true
        failed = true
        return value unless cb?
        return cb null, value
      # throw other errors back
      throw err unless cb?
      return cb err
    finally
      # do the real subcheck
      # if no check defined use array/object because of checking subvalues
      # against references
      options ?= { type: 'array' } if Array.isArray value
      if typeof value is 'object'
        options ?= { type: 'object' } unless value.REF?
      unless options
        debug "#{@pathname path} finished", chalk.grey util.inspect value
        @checked.push pathname unless pathname in @checked or failed
        return value unless cb?
        return cb null, value
      debug "#{@pathname path} check as #{options.type}"
      lib = getTypeLib options
      unless cb?
        # sync call sync
        unless lib.sync?.type?
          return new Error "Could not synchronously call #{options.type} check in
          #{@pathname path}."
        try
          result = lib.sync.type @, path, options, value
          debug "#{@pathname path} finished", chalk.grey util.inspect result
          @checked.push pathname unless pathname in @checked or failed
          return result
        catch err
          return value if err.message is 'EAGAIN'
          throw err
      else
        # async call async
        if lib.async?.type?
          return lib.async.type @, path, options, value, (err, result) ->
            unless err
              debug "#{@pathname path} finished", chalk.grey util.inspect result
              @checked.push pathname unless pathname in @checked or failed
            return cb null, value if err.message is 'EAGAIN'
            cb err, result
        # async call sync
        try
          result = lib.sync.type @, path, options, value
        catch err
          return cb null, value if err.message is 'EAGAIN'
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
