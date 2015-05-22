# IP Address validation
# =================================================

# work values
#
# - lastType - the type of the last checked reference to ensure security
# - data - structure to work on
# - pos - array defining the current position in data
# - dir - set to base directory for file relative file paths
# - structSearch - set if first element is done (within findData())
# - context - alternative data object


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
util = require 'util'
chalk = require 'chalk'
# alinex modules
async = require 'alinex-async'
{object,array} = require 'alinex-util'
# include classes and helper
ValidatorCheck = require './check'

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

# check that there are references in the object
exists = module.exports.exists = (value) ->
  return false unless typeof value is 'string'
  Boolean value.match /<<<.*>>>/

replace = module.exports.replace = (value, work={}, cb) ->
  if typeof work is 'function'
    cb = work
    work = {}
  return cb null, value unless exists value
  debug "replace #{util.inspect value}..."
  # step over parts
  refs = value.split /(<<<.*?>>>)/
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
  debug chalk.grey "check part #{util.inspect value}"
  # replace <<< and >>> and split into alternatives
  async.map value[3..-4].split(/\s+\|\s+/), (alt, cb) ->
    # split into paths and call
    uris = alt.split(/#/)
    # return default value
    if uris.length is 1 and not ~alt.indexOf '://'
      debug chalk.grey "#{util.inspect alt} -> default value: #{util.inspect alt}"
      return cb null, alt
    # search the uris
    find uris, work, (err, result) ->
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
  # get first element of path
  [proto,path] = list.shift().split /:\/\//
  unless path
    # return if no data to work on
    return cb() unless work.data?
    # set protocol missing uris
    path = proto
    proto if typeof work.data is 'string' then 'range' else 'match'
    proto = 'check' if proto = 'range' and path[0] = '{'
  # find type handler
  proto = proto.toLowerCase()
  type = protocolMap[proto] ? proto
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
    return cb err, result unless exists result
    debug chalk.grey 'rerun replace on subdata'
    replace data, object.clone(work), cb

findType =
  check:  (proto, path, work, cb) ->
    value
  range:  (proto, path, work, cb) ->
    value
  match:  (proto, path, work, cb) ->
    value
  env: (proto, path, work, cb) ->
    cb null, process.env[path]
  struct: (proto, path, work, cb) ->
    cb null, findData path, work
  context: (proto, path, work, cb) ->
    cb null, findData path, object.extend {}, work,
      data: work.context
  file: (proto, path, work, cb) ->
    fs = require 'alinex-fs'
    fspath = require 'path'
    path = fspath.resolve work.dir, path if work.dir?
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
    opt.cwd = work.dir if work.dir?
    exec path, opt, cb


findData = (path, work) ->
  unless work.structSearch?
    work = object.clone work
  # split path
  path = path.replace('/\/+$/','').split /\/+/ if typeof path is 'string'
  work.pos ?= []
  # process first level
  cur = path.shift()
  if cur is ''
    work.pos = []
  else
    if getData(work.data, work.pos)[cur]?
      work.pos.push cur
    else
      return undefined if work.structSearch
      # search backwards neighbors and parent
      done = false
      if work.pos.length > 1
        for i in [work.pos.length-2..0]
          if getData(work.data, work.pos[0..i])[cur]?
            work.pos = work.pos[0..i]
            work.pos.push cur
            done = true
            break
      unless done
        if work.data[cur]?
          work.pos = [cur]
          done = true
      return undefined unless done
  work.structSearch = true
  # go on for more level if existing
  return findData path, work if path.length
  # if not use the current path and return this value
  getData work.data, work.pos

getData = (data, pos) ->
  return data unless pos.length
  result = data
  for i in [0..pos.length-1]
    #console.log '-->', result, pos[i]
    result = result[pos[i]]
    #console.log '--=', result
  return result

