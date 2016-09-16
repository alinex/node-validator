###
Reference Resolving
=================================================
###

# This methods will be called to support references in schema definition and
# values from the Worker instance.


# Node Modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
chalk = require 'chalk'
async = require 'async'
fspath = require 'path'
# alinex modules
util = require 'alinex-util'


# Setup
# -------------------------------------------------
# MAXRETRY defines the time to wait till the references should be solved
TIMEOUT = 10 # checking every 10ms
MAXRETRY = 10000 # waiting for 10 seconds at max

# defines specific type handler for some protocols
protocolMap =
  http: 'web'
  https: 'web'

# to ensure security a reference can only call references with lower precedence
typePrecedence =
  env: 5
  struct: 4
  context: 3
  file: 2
  cmd: 2
  web: 1


# External Methods
# -------------------------------------------------

# Check if there are references in the value or object's direct properties.
#
# @param {String|Array|Object} value to check for references
# @return {Boolean} `true` if a reference exists
exists = exports.exists = (value) ->
  # checking in arrays
  if Array.isArray value
    for e in value
      return true if typeof e is 'string' and e.match /<<<[^]*>>>/
    return false
  # checking in objects
  if typeof value is 'object'
    for _, e of value
      return true if typeof e is 'string' and e.match /<<<[^]*>>>/
    return false
  # normal checking in string
  return false unless typeof value is 'string'
  Boolean value.match /<<<[^]*>>>/

# Replace references with there referenced values.
#
# @param {String|Array|Object} value to replaces references within
# @param {String} path position in structure where value comes from
# @param {Object} struct complete value object
# @param {Object} context additional object
# @param {Function(Error, value)} cb callback which is called with resulting value
# @param {Boolean} clone should the object be cloned instead of changed
exports.replace = (value, path = '', struct, context, cb, clone = false) ->
  return cb null, value unless exists value
  # for arrays and objects
  if typeof value is 'object'
    copy = if clone
      if Array.isArray value then [] else {}
    else value
    async.eachOf value, (e, k, cb) ->
      copy[k] ?= e # reference element if cloned
      return cb() unless exists e
      multiple e, "#{path}/#{k}", struct, context, (err, result) ->
        return cb err if err
        copy[k] = result
        cb()
    , (err) ->
      return cb err if err
      cb null, copy
  # for strings
  else multiple value, path, struct, context, cb


# Helper Methods
# -------------------------------------------------

# Replace multiple references in text entry.
#
# @param {String} value to replace references
# @param {String} path position in structure where value comes from
# @param {Object} struct complete value object
# @param {Object} context additional object
# @param {Function(Error, value)} cb callback which is called with resulting value
multiple = (value, path, struct, context, cb) ->
  debug "#{path}: replace #{util.inspect value}..."
  # step over multiple references
  async.map value.split(/(<<<[^]*?>>>)/), (v, cb) ->
    return cb null, v unless ~v.indexOf '<<<' # no reference
    v = v[3..-4].trim() # replace <<< and >>>
    alternatives v, path, struct, context, cb
  , (err, results) ->
    return cb err if err
    # combine reference together
    result = results.join ''
    if result is '' and results.length is 3 and not results[1]?
      return cb() # return undefined
    debug "#{path}: #{util.inspect value} is replaced by #{util.inspect result}"
    cb null, result

# Resolve alternative sources which are separated by ` | ` and the first possible
# alternative should be used.
#
# @param {String} value to replace references
# @param {String} path position in structure where value comes from
# @param {Object} struct complete value object
# @param {Object} context additional object
# @param {Function(Error, value)} cb callback which is called with resulting value
alternatives = (value, path, struct, context, cb) ->
  debug chalk.grey "#{path}: resolve #{util.inspect value}..."
  first = true
  async.map value.split(/\s+\|\s+/), (alt, cb) ->
    # automatically set first element to `struct` if no other protocol set
    alt = "struct://#{alt}" if first and not ~alt.indexOf '://'
    first = false
    # split uri into anchored separated paths
    list = util.string.rtrim alt, '#'
    .split /#/
    # return default value
    if list.length is 1 and not ~alt.indexOf '://'
      debug chalk.grey "#{path}: #{util.inspect alt} -> use as default value"
      return cb null, alt
    # read value from given uri parts
    read list, path, struct, context, (err, result) ->
      return cb err if err
      debug chalk.grey "#{path}: #{util.inspect alt} -> result: #{util.inspect result}"
      cb null, result
  , (err, results) ->
    return cb err if err
    # use first alternative
    for result in results
      return cb null, result if result?
    cb()

# This method is called with all the uri parts as value list and will search the
# real value of the first uri part, pass it on to the second search as data and so
# on. The result will be from the last uri path.
#
# @param {Array} list to replace references
# @param {String} path position in structure where value comes from
# @param {Object} struct complete value object
# @param {Object} context additional object
# @param {Function(Error, value)} cb callback which is called with resulting value
# @param {String} last type of handler used to get data element
# @param {Object} data resolved data from previous read
read = (list, path, struct, context, cb, last, data) ->
  # get type of uri part
  src = list.shift()
  return cb null, struct unless src # empty anchor return complete structure
  # detect protocol
  [proto, loc] = src.split /:\/\//
  loc ?= proto
  proto = switch proto[0]
    when '{' then 'check'
    when '%' then 'split'
    when '/' then 'match'
    when '$' then 'parse'
    else
      if src.match /^\d/ then 'range'
      else unless ~src.indexOf '://'  then 'object'
      else proto
  if proto is 'parse' and ~loc.indexOf '$join'
    proto = 'join'
  # return if not possible without data (incorrect use)
  if src[0..proto.length-1] isnt proto and not data?
    return cb new Error "Incorrect use of #{proto} without data from previous element"
  # add automatic conversion of data if needed
  switch
    when typeof data is 'string'
      switch proto
        when 'range'
          list.unshift src
          proto = 'split'
          loc = '%\n'
        when 'object'
          list.unshift src
          proto = 'parse'
          loc = '$auto'
    when Array.isArray data
      switch proto
        when 'object', 'split', 'match'
          list.unshift src
          proto = 'join'
          loc = '$join'
  # check for impossible result data
  if (
    (not Array.isArray(data) and proto in ['range', 'join']) or
    (typeof data isnt 'string' and proto in ['split', 'match', 'parse']) or
    (typeof data isnt 'object' and proto is 'object')
    )
      debug chalk.magenta "#{path}: stop at part #{proto}://#{path} because wrong result type"
      return cb()
  proto = proto.toLowerCase()
  # find type handler
  type = protocolMap[proto] ? proto
  # check for correct handler
  unless handler[type]?
    return cb new Error "No handler for protocol #{proto} references defined"
  # check precedence for next uri
  if last? and typePrecedence[type] > typePrecedence[last?]
    return cb new Error "#{type}-reference can not be called from #{last}-reference
    for security reasons"
  debug chalk.grey "#{path}: #{type} call with #{proto}://#{loc}"
  # run type handler and return if nothing found
  handler[type] proto, loc, data, path, struct, context, (err, result) ->
    return cb err if err
    unless result # no result so stop this uri
      if list.length # more to do
        debug chalk.grey util.inspect("#{proto}://#{path}") + " -> result: ---"
      return cb()
    if list.length # more to do
      debug chalk.grey util.inspect("#{proto}://#{path}") + " -> result: #{util.inspect result}"
    # no reference in result
    return cb null, result unless list.length # stop if last entry of uri path
    # process next list entry
    read list, path, struct, context, cb, type, result

# Search for data using relative or absolute path specification.
#
# @param {String} loc path to search
# @param {String} current path position in structure
# @param {Object} data complete value object
# @param {Function(Error, value)} cb callback which is called with resulting value
pathSearch = (loc, path = '', data, cb) ->
  # direct search
  q = fspath.resolve "/#{path}", loc
  # retry read till there is no reference found or timeout
  async.retry
    times: MAXRETRY
    interval: TIMEOUT
  , (cb) ->
    result = util.object.pathSearch data, q
    if exists result
      return cb new Error "Reference pointing to other reference which can not be resolved"
    cb null, result
  , (err, result) ->
    return cb err if err
    if result
      debug chalk.grey "#{path}: succeeded data read at #{q}"
      return cb null, result
    debug chalk.grey "#{path}: failed data read at #{q}"
    # search neighbors by sub call on parent
    if ~path.indexOf '/'
      return pathSearch loc, fspath.dirname("/#{path}"), data, cb
    # neither found
    cb()


# Protocoll Handlers
# -------------------------------------------------

handler =

  # Read from value structure.
  #
  struct: (proto, loc, data, path, struct, context, cb) ->
    pathSearch loc, path, struct, cb

  # Read from additional context.
  #
  context: (proto, loc, data, path, struct, context, cb) ->
    pathSearch loc, null, context, cb

  # Accessing environment variables.
  #
  env: (proto, loc, data, path, struct, context, cb) ->
    cb null, process.env[loc]
