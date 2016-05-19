# IP Address validation
# =================================================

# The following properties are used:
#
# - spec - reference to the original validation call
#   - name - (string) descriptive name of the data
#   - schema - (object) structure to check
#   - context - (object) additional data structure
#   - dir - set to base directory for file relative file paths
# - path - array containing the current path
# - pos - reference to schema position at this path
# - debug - output of current path for debugging
# - value - value at this path

# While working on the data the following values will be added:
#
# - data - structure to work on (schema or context)
# - lastType - the type of the last checked reference to ensure security


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
chalk = require 'chalk'
async = require 'async'
vm = null # load on demand
fspath = null # load on demand
request = null # load on demand
exec = null # load on demand
# alinex modules
util = require 'alinex-util'
object = util.object
fs = null # load on demand
formatter = null # load on demand
# include classes and helper
check = require './check'

# Configuration
# -------------------------------------------------
# MAXRETRY defines the time to wait till the references should be solved
MAXRETRY = 10000 # waiting for 10 seconds at max
TIMEOUT = 10 # checking every 10ms

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

# Have references
# -------------------------------------------------
# Check if there are references in the object.
exists = exports.exists = (value) ->
  return false unless typeof value is 'string'
  Boolean value.match /<<<[^]*>>>/

# Replace references
# -------------------------------------------------
# This is called from the check to resolve the references first before running
# the real check. If there are no references it will return immediately.
exports.replace = (value, work={}, cb) ->
  # maybe called without work (mostly for)
  if typeof work is 'function'
    cb = work
    work = {}
  return cb null, value unless exists value
  work.data ?= work.spec?.value
  debug "replace #{util.inspect value}..."
  # step over parts
  refs = value.split /(<<<[^]*?>>>)/
  refs = [refs[1]] if refs.length is 3 and refs[0] is '' and refs[2] is ''
  # check all references
  async.map refs, (v, cb) ->
    findAlternative v, work, cb
  , (err, results) ->
    return cb() if err
    if results.length is 1
      # return first result if only one reference used
      debug "#{util.inspect value} is replaced by #{util.inspect results[0]}"
      return cb null, results[0]
    # combine reference together
    result = results.join ''
    debug "#{util.inspect value} is replaced by #{util.inspect result}"
    cb null, result

# Helper methods
# -------------------------------------------------

# ### search through alternative sources
# Alternative sources are separated by ` | ` and the first possible alternative
# should be used.
findAlternative = (value, work={}, cb) ->
  return cb null, value unless ~value.indexOf '<<<'
  # replace <<< and >>> and split into alternatives
  first = true
  async.map value[3..-4].split(/\s+\|\s+/), (alt, cb) ->
    # automatically set first element to `struct` if no other protocol set
    if first and not ~alt.indexOf '://'
      alt = "struct://#{alt}"
    first = false
    # split uri into anchored separated paths
    alt = alt[0..alt.length-2] while alt[alt.length-1] is '#'
    uriPart = alt.split /#/
    # return default value
    if uriPart.length is 1 and not ~alt.indexOf '://'
      debug chalk.grey "#{util.inspect alt} -> default value: #{util.inspect alt}"
      return cb null, alt
    # read value from given uri parts
    find uriPart, work, (err, result) ->
      if err
        debug chalk.grey "#{util.inspect alt} -> failed: #{err.message}"
        return cb err
      debug chalk.grey "#{util.inspect alt} -> result: #{util.inspect result}"
      cb null, result
  , (err, results) ->
    # find first alternative
    for result in results
      return cb null, result if result?
    cb()

# ### Find reference
# This method is called with all the uri parts as list and will search the
# value of the first uri part, pass it on to the second search as data and so
# on. The result will be from the last uri path.
find = (list, work={}, cb) ->
  # get type of uri part
  def = list.shift()
  return cb null, work.data unless def # empty anchor
  # detect protocol
  [proto, path] = def.split /:\/\//
  path ?= proto
  proto = switch proto[0]
    when '{' then 'check'
    when '%' then 'split'
    when '/' then 'match'
    when '$' then 'parse'
    else
      if def.match /^\d/ then 'range'
      else unless ~def.indexOf '://'  then 'object'
      else proto
  if proto is 'parse' and ~path.indexOf '$join'
    proto = 'join'
  # return if not possible without data (incorrect use)
  return cb() if def[0..proto.length-1] isnt proto and not work.data?
  # run automatic conversion of data if needed
  switch
    when typeof work.data is 'string'
      switch proto
        when 'range'
          list.unshift def
          proto = 'split'
          path = '%\n'
        when 'object'
          list.unshift def
          proto = 'parse'
          path = '$auto'
    when Array.isArray work.data
      switch proto
        when 'object', 'split', 'match'
          list.unshift def
          proto = 'join'
          path = '$join'
  # check for impossible result data
  if (
    (not Array.isArray(work.data) and proto in ['range', 'join']) or
    (typeof work.data isnt 'string' and proto in ['split', 'match', 'parse']) or
    (typeof work.data isnt 'object' and proto is 'object')
    )
      debug chalk.grey "stop at part #{proto}://#{path} because wrong result type"
      return cb()
  # find type handler
  proto = proto.toLowerCase()
  type = protocolMap[proto] ? proto
  debug chalk.grey "check part " + util.inspect "#{proto}://#{path}"
  # check for correct handler
  unless findType[type]?
    return cb new Error "No handler for protocol #{proto} for references defined"
  # check precedence for next uri
  if work.lastType? and typePrecedence[type] > typePrecedence[work.lastType?]
    return cb new Error "#{type}-reference can not be called from #{proto}-reference
    for security reasons"
  # run type handler and return if nothing found
  work.lastType = type
  findType[type] proto, path, work, (err, result) ->
    return cb err if err
    unless result # no result so stop this uri
      if list.length
        debug chalk.grey util.inspect("#{proto}://#{path}") + " -> result: ---"
      return cb()
    if list.length
      debug chalk.grey util.inspect("#{proto}://#{path}") + " -> result: #{util.inspect result}"
    # no reference in result
    unless exists result
      return cb null, result unless list.length # stop if last entry of uri path
      work = util.clone work
      work.data = result
      return find list, work, cb
    # check for retry
    work.retry ?= 0
    if work.retry > MAXRETRY/TIMEOUT
      work.spec.failed = true
      return throw Error "Stopped because of circular references at
      #{work.spec.name}/#{work.path.join '/'}"
    # retry the same call again
    list.unshift def
    setTimeout ->
      return if work.spec.failed # processing already stopped
      work.retry++
      find list, work, cb
    , TIMEOUT

# ### Find value of specific type
# This is a collection of methods for specific protocols.
findType =
  # #### Value checks
  check: (proto, path, work, cb) ->
    # get the check schema reading as js
    vm ?= require 'vm'
    schema = vm.runInNewContext "x=#{path}"
    # run the subcheck
    name = work.spec?.name ? 'value'
    check.run
      name: name + '#ref'
      schema: schema
      value: work.data
    , (err, value) ->
      if err
        debug chalk.grey "'#{proto}://#{path}' -> check failed: #{err.message}"
        return cb()
      cb null, value
  # #### Splitting of strings
  split: (proto, path, work, cb) ->
    path = path[1..]
    splitter = path.split('//').map (s) -> new RegExp s
    splitter.push '' if splitter.length is 1
    result = work.data.split(splitter[0]).map (t) ->
      col = t.split splitter[1]
      col.unshift t
      col
    result.unshift null
    cb null, result
  # #### Matching strings
  match: (proto, path, work, cb) ->
    re = path.match /\/([^]*)\/(i?)/
    re = new RegExp re[1], "#{re[2]}g"
    cb null, work.data.match re
  # #### Special parsing of string
  parse: (proto, path, work, cb) ->
    formatter ?= require 'alinex-formatter'
    format = path[1..]
    format = null if format is 'auto'
    formatter.parse work.data, format, (err, result) ->
      cb null, result
  # #### Range selection in array
  range: (proto, path, work, cb) ->
    # split multiple specifiers
    rows = path.match ///
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
      if cols? and Array.isArray work.data[1]
        # get columns
        for drow in work.data[row.from..row.to]
          data = []
          for col in cols
            col = col.match ///
              (\d+) # first column
              (?:-(\d+))? # end of column range
              /// #path.split ','
            col.from = parseInt col[1]
            col.to = if col[2]? then parseInt col[2] else col.from
            data = data.concat drow[col.from..col.to]
          result.push data
      else
        # get single row
        for drow in work.data[row.from..row.to]
          result.push drow[0]
    return cb() unless result.length
    result = result[0] if result.length is 1
    result = result[0] if result.length is 1
    cb null, result
  # #### Path selection in object
  object: (proto, path, work, cb) ->
    cb null, object.pathSearch work.data, path
  # #### Join array together
  join: (proto, path, work, cb) ->
    path = path[6..]
    splitter = if path then path.split '//' else [', ']
    cb null, arrayJoin work.data, splitter
  # #### Accessing environment variable
  env: (proto, path, work, cb) ->
    cb null, process.env[path]
  # #### Read from value structure
  struct: (proto, path, work, cb) ->
    findData path, work, cb
  # #### Read from additional context
  context: (proto, path, work, cb) ->
    cb null, object.pathSearch work.spec?.context, path
  # #### Read from file
  file: (proto, path, work, cb) ->
    fs ?= require 'alinex-fs'
    fspath ?= require 'path'
    path = fspath.resolve work.spec.dir, path if work.spec?.dir?
    fs.realpath path, (err, path) ->
      return cb err if err
      fs.readFile path, 'utf-8', cb
  # #### Read from web resource
  web: (proto, path, work, cb) ->
    request ?= require 'request'
    request
      uri: "#{proto}://#{path}"
      followAllRedirects: true
    , (err, response, body) ->
      # error checking
      return cb err if err
      if response.statusCode isnt 200
        return cb new Error "Server send wrong return code: #{response.statusCode}"
      return cb() unless body?
      cb null, body
  # #### Read from command output
  cmd: (proto, path, work, cb) ->
    exec ?= require('child_process').exec
    opt = {}
    opt.cwd = work.spec.dir if work.spec?.dir?
    exec path, opt, (err, result) ->
      return cb err if err
      cb null, result.trim()

# ### Read from value structure
findData = (path, work, cb) ->
  # split path
  path = path.replace('/\/+$/', '').split /\/+/ if typeof path is 'string'
  work.path ?= []
  # find first level
  first = path[0]
  # absolute path, go on
  return cb null, object.pathSearch work.data, path[1..] if first is ''
  # search at current position
  skip = 0
  skip++ while path[skip] is '..'
  result = object.pathSearch work.data, work.path[0..work.path.length-skip-1].concat path[skip..]
  if result and work.spec?.done?
    checkpath = work.path[0..work.path.length-skip-1].concat(path[skip..]).join '/'
    unless checkpath in work.spec.done
      # check for retry
      work.retry ?= 0
      if work.retry > MAXRETRY/TIMEOUT
        work.spec.failed = true
        return throw Error "Stopped because of uncheckable #{work.spec.name}/#{checkpath}"
      return setTimeout ->
        return if work.spec.failed # processing already stopped
        work.retry++
        # reread value from spec
        work.data = work.spec.value
        findData path, work, cb
      , TIMEOUT
  return cb null, result if result
  # check if not at the end
  return cb() unless work.path.length
  # search neighbors by sub call on parent
  sub = util.clone work
  sub.spec = work.spec
  sub.path.pop()
  findData path, sub, cb

# ### Recursively join array of arrays together
arrayJoin = (data, splitter) ->
  glue = if splitter.length is 1 then splitter[0] else splitter.shift()
  result = ''
  for v in data
    v = arrayJoin v, splitter if Array.isArray v
    result += glue if result
    result += v
  result
