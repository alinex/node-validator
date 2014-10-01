# Check class
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator')
util = require 'util'
async = require 'async'
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
    for key in Object.keys @options
      @options[key] = @ref2value [''], @options[key], key

  # ### Create error message
  # This is called by the subclasses
  error: (path, options, value, err) ->
    unless options
      throw new Error "Validator called without options."
    source = [@source].concat(path).join '.'
    message = "#{err.message} in #{@source}"
    message += '.' + path.join '.' if path and path.length
    if options.title?
      message += " '#{options.title}'"
    message += '. '
    if options.description?
      message += "It should contain #{options.description}. "
    message += '\n' + ValidatorCheck.describe options
    new Error message

  # ### Synchronous check
  sync: ->
    debug "check sync #{@options.type} in #{@source}"
    lib = getTypeLib(@options)
    unless lib.sync?.type?
      return new Error "Could not synchronously call #{@options.type} check in #{@source}."
    try
      result = @value
      while @runAgain
        @runAgain = false
        result = lib.sync.type @, [], @options, result
      debug "check succeeded for #{@source}"
      result
    catch err
      debug "check failed with #{err}"
      throw err

  # Asynchronous check
  async: (cb) ->
    debug "check async #{@options.type} in #{@source}"
    lib = getTypeLib(@options)
    # call async lib
    if lib.async?.type?
      result = @value
      return async.whilst =>
        @runAgain is true
      , (cb) =>
        @runAgain = false
        lib.async.type @, [], @options, result, (err, res) ->
          result = res
          cb err, res
      , (err) =>
        if err
          debug "check failed with #{err}"
          return cb err
        debug "check succeeded for #{@source}"
        cb null, result
    # alternatively run sync code
    try
      result = @value
      while @runAgain
        @runAgain = false
        result = lib.sync.type @, [], @options, result
      debug "check succeeded for #{@source}"
      cb null, result
    catch err
      debug "check failed with #{err}"
      cb err


  # ### Pathname to be printed
  pathname: (path) ->
    if path? and path.length
      return "#{@source}.#{path.join '.'}"
    @source

  # ### Get value with reference support
  # will set the runAgain flag if necessary
  #
  ref2value: (path, value, key) ->
    pathname = path.join '.'
    unless value and typeof value is 'object' and value.reference? and value.source?
      @checked.push pathname unless pathname in @checked
      return value
    # it's a reference, find path
    source = value.source.split '.'
    obj = null
    switch value.reference
      when 'absolute'
        obj = @value
        unless pathname in @checked
          throw new Error 'EAGAIN'
        debug "use absolute reference to '#{source.join '.'}' for #{path.join '.'}.#{key}"
      when 'relative'
        obj = @value
        newpath = path.slice()
        while source[0][0] is '<'
          newpath.shift()
          source[0] = source[0][1..]
        source = newpath.concat source
        unless pathname in @checked
          throw new Error 'EAGAIN'
        debug "use relative reference to '#{source.join '.'}' for #{path.join '.'}.#{key}"
      when 'external'
        obj = @data
        debug "use external reference to '#{source.join '.'}' for #{path.join '.'}.#{key}"
    # read value
    for part in source
      unless obj[part]?
        debug "reference '#{source.join '.'}' not found"
        return null
      obj = obj[part]
    # call operations
    if value.operation
      debug "run operation on referenced value"
      obj = value.operation obj
    # return resulting value
    obj

  subcall: (path, options, value, cb) ->
    # check for references
    try
      for key in Object.keys options
        options[key] = @ref2value path, options[key], key
    catch err
      if err.message is 'EAGAIN'
        @runAgain = true
        return value unless cb?
        return cb null, value
      throw err unless cb?
      return cb err
    finally
      debug "subcall for #{options.type} in #{@pathname path}"
      lib = getTypeLib(options)
      unless cb?
        # sync call sync
        unless lib.sync?.type?
          return new Error "Could not synchronously call #{options.type} check in
          #{@pathname path}."
        return lib.sync.type @, path, options, value
      else
        # async call async
        if lib.async?.type?
          return lib.async.type @, path, options, value, cb

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
  throw Error "Undefined type #{name}"

