# Check class
# =================================================

# Node modules
# -------------------------------------------------
debug = require('debug')('validator')
util = require 'util'
# internal classes and helper
reference = require './reference'


# Class for validation
# -------------------------------------------------
# ### Instance properties
#
# - source - original name of source
# - options - check definition
# - value - check value
# - data - additional references for checks
# - runAgain - true for another check round
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

  # ### Create error message
  # This is called by the subclasses
  error: (path, options, value, err) ->
    source = [@source].concat(path).join '.'
    message = "#{err.message} in #{@source}"
    if options.title?
      message += " '#{options.title}'"
    message += '.'
    if options.description?
      message += "It should contain #{options.description}. "
    new Error message

  # ### Synchronous check
  sync: ->
    debug "start new check of #{@source}"
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
    cb null, value

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

