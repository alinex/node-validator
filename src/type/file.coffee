# Domain name validation
# =================================================

# Check the value as valid file or directory entry.
#
# __Sanitize options:__
#
# - `basedir` - (string) relative paths are calculated from this directory
# - `resolve` - (bool) should the given value be resolved to a full path
#
# __Check options:__
#
# - `exists` - (bool) true to check for already existing entry
# - `find` - (array or function) list of directories in which to search for the file
# - `filetype` - (string) check against inode type: f, file, d, dir, directory, l, link


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:file')
util = require 'util'
chalk = require 'chalk'
fspath = require 'path'
# alinex modules
fs = require 'alinex-fs'
async = require 'alinex-async'
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A valid filesystem entry. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if work.pos.exists
    text += "The file has to exist. "
  if work.pos.basedir
    text += "Relative paths are calculated from #{work.pos.basedir}. "
  if work.pos.resolve
    text += "The path will be resolved to it's absolute path. "
  if work.pos.find
    text += "A search for the file will be done. "
  if work.pos.filetype
    text += "The file have to be of type '#{work.pos.filetype}'. "
  cb null, text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  value = work.value
  # sanitize
  if typeof value isnt 'string'
    return work.report (new Error "Could not find the file #{value}"), cb
  value = fspath.normalize value
  value = value[..-2] if value[-1..] is '/'
  # get basedir
  basedir = fspath.resolve work.pos.basedir ? '.'
  # validate
  find work, value, (err, found) ->
    return cb err if err
    unless found
      return work.report (new Error "Could not find the file #{value}"), cb
    # resolve
    filepath = fspath.resolve basedir, found
    found = filepath if work.pos.resolve
    exists work, filepath, (err) ->
      return cb err if err
      filetype work, found, (err) ->
        return cb err if err
        debug "#{work.debug} result #{util.inspect value}"
        cb null, found

find = (work, value, cb) ->
  return cb null, value unless work.pos.find
  search =  if typeof work.pos.find is 'function' then work.pos.find() else work.pos.find
  unless search?.length
    return work.report (new Error "Wrong find option, array is needed for file validation."), cb
  # search in list
  async.map search, (dir, cb) ->
    debug "#{work.debug} search in #{dir}..."
    fs.find dir,
      include: value
    , (err, list) ->
      cb null, list
  , (err, lists) ->
    for list in lists
      # retrieve first found
      return cb null, list[0] if list?.length
    # return null if nothing found
    cb()

exists = (work, value, cb) ->
  return cb() unless work.pos.exists or work.pos.filetype
  fs.exists value, (exists) ->
    return cb() if exists
    work.report (new Error "The given file '#{value}' has to exist."), cb

filetype = (work, value, cb) ->
  return cb() unless work.pos.filetype
  fs.lstat value, (err, stats) ->
    return cb err if err
    switch work.pos.filetype
      when 'file', 'f'
        return cb() if stats.isFile()
        debug "#{work.debug} skip #{value} because not a file entry"
      when 'directory', 'dir', 'd'
        return cb() if stats.isDirectory()
        debug "#{work.debug} skip #{value} because not a directory entry"
      when 'link', 'l'
        return cb() if stats.isSymbolicLink()
        debug "#{work.debug} skip #{value} because not a link entry"
      when 'fifo', 'pipe', 'p'
        return cb() if stats.isFIFO()
        debug "#{work.debug} skip #{value} because not a FIFO entry"
      when 'socket', 's'
        return cb() if stats.isSocket()
        debug "#{work.debug} skip #{value} because not a socket entry"
    work.report (new Error "The given file '#{value}' is not a #{work.pos.filetype} entry."), cb

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'string'
          optional: true
        basedir:
          type: 'string'
          default: '.'
        resolve:
          type: 'boolean'
          default: false
        exists:
          type: 'boolean'
          default: false
        find:
          type: 'array'
          optional: true
          entries:
            type: 'string'
        filetype:
          type: 'string'
          lowerCase: true
          values: [
            'f', 'file'
            'd', 'dir', 'directory'
            'l', 'link'
          ]
          optional: true
    value: schema
  , cb

