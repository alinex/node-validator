###
URL
=================================================

__Sanitize options:__
- `basedir` - `String` relative paths are calculated from this directory
- `resolve` - `Boolean` should the given value be resolved to a full path

__Check options:__
- `exists` - `Boolean` true to check for already existing entry
- `find` - `Array|Function` list of directories in which to search for the file
- `filetype` - `String` check against inode type: f, file, d, dir, directory, l, link


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
async = require 'async'
fspath = require 'path'
# alinex modules
fs = require 'alinex-fs'
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A valid url (unified resource locator). '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if @schema.exists
    text += "The file has to exist. "
  if @schema.basedir
    text += "Relative paths are calculated from #{@schema.basedir}. "
  if @schema.resolve
    text += "The path will be resolved to it's absolute path. "
  if @schema.find
    text += "A search for the file will be done. "
  if @schema.filetype
    text += "The file have to be of type '#{@schema.filetype}'. "
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # sanitize
  if typeof @value isnt 'string'
    return @sendError "A string is needed as filename", cb
  @value = fspath.normalize @value
  @value = @value[..-2] if @value[-1..] is '/'
  # get basedir
  basedir = fspath.resolve @schema.basedir ? '.'
  # validate
  find.call this, @value, (err, found) =>
    return cb err if err
    unless found
      return @sendError "Could not find the file #{@value}", cb
    # resolve
    filepath = fspath.resolve basedir, found
    found = filepath if @schema.resolve
    exists.call this, filepath, (err) =>
      return cb err if err
      filetype.call this, found, (err) =>
        return cb err if err
        @value = found
        # done checking and sanuitizing
        @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "File"
  description: "a file schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'string'
      optional: true
    basedir:
      title: "Base Directory"
      description: "the directory to use for relative link resolving"
      type: 'string'
      default: '.'
    resolve:
      title: "Resolve"
      description: "a flag to resolve relative links to absolute ones"
      type: 'boolean'
      default: false
    exists:
      title: "Exists"
      description: "a flag if the file have to exist"
      type: 'boolean'
      default: false
    find:
      title: "Find"
      description: "the directories in which to search for the file"
      type: 'array'
      toArray: true
      optional: true
      entries:
        title: "Find Directory"
        description: "the directory in which to search for the file"
        type: 'string'
    filetype:
      title: "File Type"
      description: "the type, the file should have"
      type: 'string'
      lowerCase: true
      values: [
        'f', 'file'
        'd', 'dir', 'directory'
        'l', 'link'
        'fifo', 'pipe', 'p'
        'socket', 's'
      ]
      optional: true
  , rules.baseSchema


# Helper
# --------------------------------------------------------------------

# @param {Array|Function} value list of directories to search in
# @param {Function(Error, String)} cb callback which is invoked with the
# resulting file path
find = (value, cb) ->
  return cb null, value unless @schema.find
  search =  if typeof @schema.find is 'function' then @schema.find() else @schema.find
  unless search?.length
    return @sendError "Wrong find option, array is needed for file validation", cb
  # search in list
  async.map search, (dir, cb) =>
    @debug "#{@name}: search in #{dir}..."
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

# @param {String} value file to check for existence
# @param {Function(Error)} cb callback with Error if file didn't exist
exists = (value, cb) ->
  return cb() unless @schema.exists or @schema.filetype
  fs.exists value, (exists) =>
    return cb() if exists
    @sendError "The given file has to exist", cb

# @param {String} value file to check
# @param {Function(Error)} cb callback with Error if file is of wrong type
filetype = (value, cb) ->
  return cb() unless @schema.filetype
  fs.lstat value, (err, stats) =>
    return cb err if err
    switch @schema.filetype
      when 'file', 'f'
        return cb() if stats.isFile()
        @debug "#{@name}: skip #{value} because not a file entry"
      when 'directory', 'dir', 'd'
        return cb() if stats.isDirectory()
        @debug "#{@name}: skip #{value} because not a directory entry"
      when 'link', 'l'
        return cb() if stats.isSymbolicLink()
        @debug "#{@name}: skip #{value} because not a link entry"
      when 'fifo', 'pipe', 'p'
        return cb() if stats.isFIFO()
        @debug "#{@name}: skip #{value} because not a FIFO entry"
      when 'socket', 's'
        return cb() if stats.isSocket()
        @debug "#{@name}: skip #{value} because not a socket entry"
    @sendError "The given file is not a #{@schema.filetype} entry", cb
