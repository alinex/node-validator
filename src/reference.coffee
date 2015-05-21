# IP Address validation
# =================================================

# work values
#
# - lastType - the type of the last checked reference to ensure security
# - data - structure to work on
# - pos - array defining the current position in data
# - structSearch - set if first element is done (within findData())
# - context - alternative data object


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
util = require 'util'
chalk = require 'chalk'
# alinex modules
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

replace = module.exports.replace = (value, work={}) ->
  return value unless  exists value
  debug "replace #{util.inspect value}..."
  # step other parts
  refs = value.split /(<<<.*?>>>)/
  combined = ''
  single = refs.length is 3 and refs[0] is '' and refs[2] is ''
  for v in refs
    result = findAlternative v, work
    unless result?
      debug "no value found for #{util.inspect value}"
      return undefined
    if single
      combined = result if result
    else
      combined += result
  debug "#{util.inspect value} is replaced by #{util.inspect combined}"
  combined

findAlternative = (value, work={}) ->
  return value unless ~value.indexOf '<<<'
  debug "alternative #{util.inspect value}"
  # replace <<< and >>> and split into alternatives
  for alt in value[3..-4].split /\s+\|\s+/
    # split into paths and call
    uris = alt.split(/#/)
    # return default value
    if uris.length is 1 and not ~alt.indexOf '://'
      debug "use default value"
      return alt
    # search the uris
    result = find uris, work
    return result if result?
  undefined

find = (list, work={}) ->
  # get first element of path
  [proto,path] = list.shift().split /:\/\//
  unless path
    # return if no data to work on
    return undefined unless work.data?
    # set protocol missing uris
    path = proto
    proto if typeof work.data is 'string' then 'range' else 'match'
    proto = 'check' if proto = 'range' and path[0] = '{'
  # find type handler
  debug "find #{proto}://#{path}"
  proto = proto.toLowerCase()
  type = protocolMap[proto] ? proto
  # check for correct handler
  unless findType[proto]?
    throw new Error "No handler for protocol #{proto} for references defined"
  # check precedence for next uri
  if work.lastType? and typePrecedence[type] > typePrecedence[work.lastType?]
    throw new Error "#{next}-reference can not be called from #{proto}-reference
    for security reasons"
  # run type handler and return if nothing found
  work.lastType = type
  result = findType[proto] proto, path, work
  if result?
    debug "found #{util.inspect result}"
    # check for another reference
    result = replace data, object.clone work if exists result
  result

findType =
  check:  (proto, path, work) ->
    value
  range:  (proto, path, work) ->
    value
  match:  (proto, path, work) ->
    value
  env: (proto, path, work) ->
    result = process.env[path]
    return result if result?
    null
  struct: (proto, path, work) ->
    findData path, work
  context: (proto, path, work) ->
    findData path, object.extend {}, work,
      data: work.context

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

