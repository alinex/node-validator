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
# - structSearch - set if first element is done (within findData())


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
util = require 'util'
chalk = require 'chalk'
# alinex modules
async = require 'alinex-async'
{object,array} = require 'alinex-util'
# include classes and helper
check = require './check'

# Configuration
# -------------------------------------------------
# defines specific type handler for some protocols
protocolMap =
  http: 'web'
  https: 'web'

# to ensure security a reference can only call references with lower precedence
typePrecedence =
  env: 5
  struct: 4
  context : 3
  file: 2
  cmd: 2
  web: 1

# Helper methods
# -------------------------------------------------

exports.check = (value, work, cb) ->
  return cb null,value unless exists value
  replace value, work, cb

# check that there are references in the object
exists = module.exports.exists = (value) ->
  return false unless typeof value is 'string'
  Boolean value.match /<<<[^]*>>>/

replace = module.exports.replace = (value, work={}, cb) ->
  if typeof work is 'function'
    cb = work
    work = {}
  return cb null, value unless exists value
  work.data ?= work.spec?.schema
  debug "replace #{util.inspect value}..."
  # step over parts
  refs = value.split /(<<<[^]*?>>>)/
  refs = [refs[1]] if refs.length is 3 and refs[0] is '' and refs[2] is ''
  # check alternatives
  async.map refs, (v, cb) ->
    findAlternative v, work, cb
  , (err, results) ->
    return cb() if err
    if results.length is 1
      debug "#{util.inspect value} is replaced by #{util.inspect results[0]}"
      return cb null, results[0]
    # combine together
    result = results.join ''
    debug "#{util.inspect value} is replaced by #{util.inspect result}"
    cb null, result


findAlternative = (value, work={}, cb) ->
  return cb null, value unless ~value.indexOf '<<<'
  # replace <<< and >>> and split into alternatives
  async.map value[3..-4].split(/\s+\|\s+/), (alt, cb) ->
    # split into paths and call
    uriPart = alt.split /#/
    # return default value
    if uriPart.length is 1 and not ~alt.indexOf '://'
      debug chalk.grey "#{util.inspect alt} -> default value: #{util.inspect alt}"
      return cb null, alt
    # search the uriPart
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

find = (list, work={}, cb) ->
  # get type of uri part
  def = list.shift().trim()
  return cb null, work.data unless def # empty anchor
  [proto,path] = def.split /:\/\//
  path ?= proto
  proto = switch proto[0]
    when '{' then 'check'
    when '%' then 'split'
    when '/' then 'match'
    when '$' then 'parse'
    else
      if def.match /^\d/ then 'range'
      else unless path then 'object'
      else proto
  # return if not possible without data
  return cb() if def[0..proto.length-1] isnt proto and not work.data?
  # run automatic conversion if needed
  if typeof work.data is 'string' and proto is 'range'
    list.unshift def
    proto = 'split'
    path = '%%\n'
  # check for impossible result data
  if (
    (not Array.isArray(work.data) and proto is 'range') or
    (typeof work.data isnt 'string' and proto in ['split','match','parse']) or
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
    return cb new Error "#{next}-reference can not be called from #{proto}-reference
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
      work = object.extend {}, work,
        data: result
      return find list, work, cb
    # result with reference
    # do another round on the result's reference
    # mabe use path of the found reference's position
    # go on in list

findType =
  check:  (proto, path, work, cb) ->
    # get the check schema reading as js
    vm = require 'vm'
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
  split:  (proto, path, work, cb) ->
    splitter = path.split('%%').map (s) -> new RegExp s
    result = work.data.split(splitter[1]).map (t) ->
      col = t.split splitter[2]
      col.unshift t
      col
    result.unshift null
    cb null, result
  match:  (proto, path, work, cb) ->
    re = path.match /\/([^]*)\/(i?)/
    re = new RegExp re[1], "#{re[2]}g"
    cb null, work.data.match re
  parse:  (proto, path, work, cb) ->
    switch path
      when '$js'
        vm = require 'vm'
        cb null, vm.runInNewContext "x=#{work.data}"
      when '$json'
        try
          result = JSON.parse work.data
        catch err
          debug chalk.grey "'#{proto}://#{path}' -> check failed: #{err.message}"
          return cb()
        cb null, result
      when '$yaml'
        yaml = require 'js-yaml'
        try
          result = yaml.safeLoad work.data
        catch err
          debug chalk.grey "'#{proto}://#{path}' -> check failed: #{err.message}"
          return cb()
        cb null, result
      when '$xml'
        xml2js = require 'xml2js'
        xml2js.parseString work.data, (err, result) ->
          if err
            debug chalk.grey "'#{proto}://#{path}' -> check failed: #{err.message}"
            return cb()
          cb null, result
      else
        cb()
  range:  (proto, path, work, cb) ->
    console.log proto,path,work
    cb null, value
  object:  (proto, path, work, cb) ->
    console.log proto,path,work
    cb null, value
  env: (proto, path, work, cb) ->
    cb null, process.env[path]
  struct: (proto, path, work, cb) ->
    cb null, findData path, work
  context: (proto, path, work, cb) ->
    cb null, findData path, object.extend {}, work,
      data: work.spec?.context
  file: (proto, path, work, cb) ->
    fs = require 'alinex-fs'
    fspath = require 'path'
    path = fspath.resolve work.spec.dir, path if work.spec?.dir?
    fs.realpath path, (err, path) ->
      return cb err if err
      fs.readFile path, 'utf-8', cb
  web: (proto, path, work, cb) ->
    request = require 'request'
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
  cmd: (proto, path, work, cb) ->
    exec = require('child_process').exec
    opt = {}
    opt.cwd = work.spec.dir if work.spec?.dir?
    exec path, opt, cb


findData = (path, work) ->
  unless work.structSearch?
    work = object.clone work
  # split path
  path = path.replace('/\/+$/','').split /\/+/ if typeof path is 'string'
  work.path ?= []
  # process first level
  cur = path.shift()
  if cur is ''
    work.path = []
  else
    if getData(work.data, work.path)?[cur]?
      work.path.push cur
    else
      return undefined if work.structSearch
      # search backwards neighbors and parent
      done = false
      if work.path.length > 1
        for i in [work.path.length-2..0]
          if getData(work.data, work.path[0..i])[cur]?
            work.path = work.path[0..i]
            work.path.push cur
            done = true
            break
      unless done
        if work.data[cur]?
          work.path = [cur]
          done = true
      return undefined unless done
  work.structSearch = true
  # go on for more level if existing
  return findData path, work if path.length
  # if not use the current path and return this value
  getData work.data, work.path

getData = (data, pos) ->
  return data unless pos.length
  result = data
  for i in [0..pos.length-1]
    #console.log '-->', result, pos[i]
    result = result[pos[i]]
    #console.log '--=', result
  return result

