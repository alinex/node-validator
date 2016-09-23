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
request = null # load on demand
exec = null # load on demand
vm = null # load on demand
# alinex modules
util = require 'alinex-util'
fs = null # load on demand
format = null # load on demand
# local helper
Worker = null # load later because of circular references

# Setup
# -------------------------------------------------
# MAXRETRY defines the time to wait till the references should be solved
TIMEOUT = 100 # checking every 10ms
MAXRETRY = 10 # waiting for 1 second at max

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
# @param {String} value to check for references
# @return {Boolean} `true` if a reference exists
exists = exports.exists = (value) ->
  # normal checking in string
  return false unless typeof value is 'string'
  Boolean value.match /<<<[^]*>>>/

# Check if there are references in the value or object's direct properties.
#
# @param {Array|Object} value to check for references
# @return {Boolean} `true` if a reference exists
existsObject = exports.existsObject = (value) ->
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

# Wait till reference is resolved.
#
# @param {Worker} worker to check value for references
# @param {Function(Error)} cb callback if reference is resolved or error if neither
exports.existsWait = (worker, cb) ->
  async.retry
    times: MAXRETRY
    interval: TIMEOUT
  , (cb) ->
    return cb() unless exists worker.value
    cb new Error "Reference #{worker.value} can not be resolved"
  , cb

# Replace references with there referenced values.
#
# @param {String|Array|Object} value to replaces references within
# @param {Worker} worker the current worker with
# - `path` position in structure where value comes from
# - `root.value` complete value object
# - `context` context additional object
# @param {Function(Error, value)} cb callback which is called with resulting value
# @param {Boolean} clone should the object be cloned instead of changed
exports.replace = (value, worker, cb, clone = false) ->
  return cb null, value unless existsObject value
  # for arrays and objects
  if typeof value is 'object'
    copy = if clone
      if Array.isArray value then [] else {}
    else value
    async.eachOf value, (e, k, cb) ->
      copy[k] ?= e # reference element if cloned
      return cb() unless existsObject e
      multiple e, "#{worker.path}/#{k}", worker.root, (err, result) ->
        return cb err if err
        copy[k] = result
        cb()
    , (err) ->
      return cb err if err
      cb null, copy
  # for strings
  else multiple value, worker.path, worker.root, cb


# Helper Methods
# -------------------------------------------------

# Replace multiple references in text entry.
#
# @param {String} value to replace references
# @param {String} path position in structure where value comes from
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
multiple = (value, path, worker, cb) ->
  path = path[1..] if path[0] is '/'
  debug "/#{path} replace #{util.inspect value}..."
  list = value.split /(<<<[^]*?>>>)/
  list = [list[1]] if list.length is 3 and list[0] is '' and list[2] is ''
  # step over multiple references
  async.map list, (v, cb) ->
    return cb null, v unless ~v.indexOf '<<<' # no reference
    v = v[3..-4] # replace <<< and >>>
    alternatives v, path, worker, cb
  , (err, results) ->
    return cb err if err
    # reference only value
    if results.length is 1
      debug "/#{path} #{util.inspect value} is replaced by #{util.inspect results[0]}"
      return cb null, results[0]
    # combine reference together
    result = results.join ''
    debug "/#{path} #{util.inspect value} is replaced by #{util.inspect result}"
    cb null, result

# Resolve alternative sources which are separated by ` | ` and the first possible
# alternative should be used.
#
# @param {String} value to replace references
# @param {String} path position in structure where value comes from
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
alternatives = (value, path, worker, cb) ->
  debug chalk.grey "/#{path} resolve #{util.inspect value}..."
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
      debug chalk.grey "/#{path} #{alt} -> use as default value".replace /\n/, '\\n'
      return cb null, alt
    # read value from given uri parts
    read list, path, worker, (err, result) ->
      return cb err if err
      debug chalk.grey "/#{path} #{alt} -> #{util.inspect result}".replace /\n/, '\\n'
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
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
# @param {String} last type of handler used to get data element
# @param {Object} data resolved data from previous read
read = (list, path, worker, cb, last, data) ->
  # get type of uri part
  src = list.shift()
  return cb null, worker.value unless src # empty anchor return complete structure
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
      debug chalk.magenta "/#{path} stop at part #{proto}://#{loc} because wrong
      result type".replace /\n/, '\\n'
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
  debug chalk.grey "/#{path} evaluating #{proto}://#{loc}".replace /\n/, '\\n'
  # run type handler and return if nothing found
  handler[type] proto, loc, data, path, worker, (err, result) ->
    if err
      debug chalk.magenta "/#{path} #{proto}://#{loc} -> failed: #{err.message}".replace /\n/, '\\n'
      return cb err
    unless result # no result so stop this uri
      if list.length # more to do
        debug chalk.grey "/#{path} #{proto}://#{loc} -> undefined".replace /\n/, '\\n'
      return cb()
    if list.length # more to do
      debug chalk.grey "/#{path} #{proto}://#{loc} -> #{util.inspect result}".replace /\n/, '\\n'
    # no reference in result
    return cb null, result unless list.length # stop if last entry of uri path
    # process next list entry
    read list, path, worker, cb, type, result

# Search for data using relative or absolute path specification.
#
# @param {String} loc path to search
# @param {String} current path position in structure
# @param {Object} data complete value object
# @param {Worker} worker the root worker with
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
pathSearch = (loc, path = '', data, worker, cb) ->
  # direct search
  q = fspath.resolve "/#{path}", loc
  # retry read till there is no reference found or timeout
  async.retry
    times: MAXRETRY
    interval: TIMEOUT
  , (cb) ->
    result = util.object.pathSearch data, q
    if exists result
      return cb new Error "Reference pointing to #{q} can not be resolved"
    if result and worker? and not (q[1..] in worker.checked)
      return cb new Error "Referenced value at #{q} is not validated"
    cb null, result
  , (err, result) ->
    if err
      debug chalk.magenta "/#{path} has a circular reference at #{q}"
      return cb err
    if result
      debug chalk.grey "/#{path} succeeded data read at #{q}"
      return cb null, result
    debug chalk.grey "/#{path} failed data read at #{q}"
    # search neighbors by sub call on parent
    if ~path.indexOf '/'
      return pathSearch loc, fspath.dirname(path), data, worker, cb
    else if path
      return pathSearch loc, null, data, worker, cb
    # neither found
    cb()

# ### Recursively join array of arrays together
arrayJoin = (data, splitter) ->
  glue = if splitter.length is 1 then splitter[0] else splitter.shift()
  result = ''
  for v in data
    v = arrayJoin v, splitter if Array.isArray v
    result += glue if result
    result += v
  result


# Protocoll Handlers
# -------------------------------------------------
# All handler are called with the same api. This contains all data which may be used
# in any handler.
#
# @param {String} proto protokoll name to use (type of handler)
# @param {String} loc location to extract
# @param {Object} data allready read data from previous read
# @param {String} base base location where to search references
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, result)} cb callback which is called with the resulting object
handler =

  # Read from value structure.
  #
  struct: (proto, loc, data, base, worker, cb) ->
    pathSearch loc, base, worker.value, worker, cb

  # Read from additional context.
  #
  context: (proto, loc, data, base, worker, cb) ->
    pathSearch loc, null, worker.context, null, cb

  # Accessing environment variables.
  #
  env: (proto, loc, data, base, worker, cb) ->
    cb null, process.env[loc]

  # Reading from locale or mounted file system.
  #
  # To specify a specific directory as current directory it can be set as context
  # variable: `currentDir`
  file: (proto, loc, data, base, worker, cb) ->
    fs ?= require 'alinex-fs'
    loc = fspath.resolve worker.context.currentDir, loc if worker.context?.currentDir?
    fs.realpath loc, (err, path) ->
      if err
        return cb() if err.code is 'ENOENT'
        return cb err
      fs.readFile path, 'utf-8', cb

  # Reading from web ressources using http and https.
  #
  web: (proto, loc, data, base, worker, cb) ->
    request ?= require 'request'
    request
      uri: "#{proto}://#{loc}"
      followAllRedirects: true
    , (err, response, body) ->
      # error checking
      if err
        return cb() if err.message.match /\bENOTFOUND\b/
        return cb err
      if response.statusCode isnt 200
        return cb() if response.statusCode is 404
        return cb new Error "Server send wrong return code: #{response.statusCode}"
      return cb() unless body?
      cb null, body

  # Reading from web ressources using http and https.
  #
  cmd: (proto, loc, data, base, worker, cb) ->
    exec ?= require('child_process').exec
    opt = {}
    opt.cwd = worker.context.currentDir if worker.context?.currentDir?
    exec loc, opt, (err, result) ->
      return cb err if err
      cb null, result.trim()

  # Value checks.
  #
  check: (proto, loc, data, base, worker, cb) ->
    # get the check schema reading as js
    vm ?= require 'vm'
    schema = vm.runInNewContext "x=#{loc}"
    # instantiate new object
    Worker ?= require './worker'
    worker = new Worker "reference-#{loc}", schema, null, data
    # run the check
    worker.check (err) ->
      return cb err if err
      cb null, worker.value

  # Splitting of strings.
  #
  split: (proto, loc, data, base, worker, cb) ->
    splitter = loc[1..].split('//').map (s) -> new RegExp s
    splitter.push '' if splitter.length is 1
    result = data.split(splitter[0]).map (t) ->
      col = t.split splitter[1]
      col.unshift t
      col
    result.unshift null
    cb null, result

  # #### Matching strings
  match: (proto, loc, data, base, worker, cb) ->
    re = loc.match /\/([^]*)\/(i?)/
    re = new RegExp re[1], "#{re[2]}g"
    cb null, data.match re

  # #### Special parsing of string
  parse: (proto, loc, data, base, worker, cb) ->
    format ?= require 'alinex-format'
    formatType = loc[1..]
    formatType = null if formatType is 'auto'
    format.parse data, formatType, (err, result) ->
      cb null, result

  # #### Range selection in array
  range: (proto, loc, data, base, worker, cb) ->
    # split multiple specifiers
    rows = loc.match ///
      \d+ # first row
      (?:-\d+)? # end of row range
      (?:\[[^\]]+\])? # column specification
      ///g #path.split ','
    result = []
    # go over rows
    for row in rows
      row = row.match ///
        (\d+) # first row
        (?:-(\d+))? # end of row range
        (?:\[([^\]]+)\])? # column specification
        /// #path.split ','
      row.from = parseInt row[1]
      row.to = if row[2]? then parseInt row[2] else row.from
      cols = row[3]?.split ','
      if cols? and Array.isArray data[1]
        # get columns
        for drow in data[row.from..row.to]
          rrows = []
          for col in cols
            col = col.match ///
              (\d+) # first column
              (?:-(\d+))? # end of column range
              /// #path.split ','
            col.from = parseInt col[1]
            col.to = if col[2]? then parseInt col[2] else col.from
            rrows = rrows.concat drow[col.from..col.to]
          result.push rrows
      else
        # get single row
        for drow in data[row.from..row.to]
          result.push drow[0]
    return cb() unless result.length
    result = result[0] if result.length is 1
    result = result[0] if result.length is 1
    cb null, result

  # #### Path selection in object
  object: (proto, loc, data, base, worker, cb) ->
    cb null, util.object.pathSearch data, loc

  # #### Join array together
  join: (proto, loc, data, base, worker, cb) ->
    loc = loc[6..]
    splitter = if loc then loc.split '//' else [', ']
    cb null, arrayJoin data, splitter
