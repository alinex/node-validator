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
# - `find` - (array) list of directories in which to search for the file
# - `filetype` - (string) check against inode type: f, file, d, dir, directory, l, link


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:file')
util = require 'util'
chalk = require 'chalk'
fs = require 'alinex-fs'
fspath = require 'path'
async = require 'alinex-async'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

module.exports = file =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A valid filesystem entry. '
      text += rules.describe.optional options
      text = text.replace /\. It's/, ' which is'
      if options.exists
        text += "The file has to exist. "
      if options.basedir
        text += "Relative paths are calculated from #{options.basedir}. "
      if options.resolve
        text += "The path will be resolved to it's absolute path. "
      if options.find
        text += "A search for the file will be done. "
      if options.filetype
        text += "The file have to be of type '#{options.filetype}'. "
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "#{check.pathname path} check: #{util.inspect(value).replace /\n/g, ''}"
      , chalk.grey util.inspect options
      # first check input type
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # sanitize
      value = fspath.normalize value
      value = value[..-2] if value[-1..] is '/'
      # get basedir
      basedir = fspath.resolve options.basedir ? '.'
      # find
      if options.find
        search =  if typeof options.find is 'function' then options.find() else options.find
        unless search?.length
          throw new Error "Wrong find option, array is needed for file validation."
        for dir in search
          debug "search in #{dir}..."
          list = fs.findSync dir,
            include: value
          break if list
        return null unless list
        value = list[0]
      # resolve
      filepath = fspath.resolve basedir, value
      value = filepath if options.resolve
      # exists
      if options.exists or options.filetype
        unless fs.existsSync filepath
          throw check.error path, options, value,
          new Error "The given file '#{value}' has to exist."
      # filetype
      if options.filetype?
        stats = fs.statSync filepath
        switch options.filetype
          when 'file', 'f'
            return value if stats.isFile()
            debug "skip #{file} because not a file entry"
          when 'directory', 'dir', 'd'
            return value if stats.isDirectory()
            debug "skip #{file} because not a directory entry"
          when 'link', 'l'
            return value if stats.isSymbolicLink()
            debug "skip #{file} because not a link entry"
          when 'fifo', 'pipe', 'p'
            return value if stats.isFIFO()
            debug "skip #{file} because not a FIFO entry"
          when 'socket', 's'
            return value if stats.isSocket()
            debug "skip #{file} because not a socket entry"
        throw check.error path, options, value,
        new Error "The given file '#{value}' is not a #{filetype} entry."
      # return value
      value

  async:
    # ### Check Type
    type: (check, path, options, value, cb) ->
      debug "#{check.pathname path} check: #{util.inspect(value).replace /\n/g, ''}"
      , chalk.grey util.inspect options
      # first check input type
      try
        value = rules.sync.optional check, path, options, value
      catch err
        return cb err
      return cb null, value unless value?
      # sanitize
      value = fspath.normalize value
      value = value[..-2] if value[-1..] is '/'
      # get basedir
      basedir = fspath.resolve options.basedir ? '.'
      # validate
      file.async.find check, path, options, value, (err, found) ->
        return cb err if err
        unless found
          return cb new Error "Could not find the file #{value} in #{check.pathname path}"
        # resolve
        filepath = fspath.resolve basedir, found
        found = filepath if options.resolve
        file.async.exists check, path, options, found, (err, found) ->
          return cb err if err
          file.async.filetype check, path, options, found, (err, found) ->
            return cb err if err
            cb null, found

    find: (check, path, options, value, cb) ->
      return cb null, value unless options.find
      search =  if typeof options.find is 'function' then options.find() else options.find
      unless search?.length
        return cb new Error "Wrong find option, array is needed for file validation."
      # search in list
      async.map search, (dir, cb) ->
        debug "search in #{dir}..."
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

    exists: (check, path, options, value, cb) ->
      return cb null, value unless options.exists or options.filetype
      fs.exists value, (exists) ->
        unless exists
          return cb check.error path, options, value,
          cb new Error "The given file '#{value}' has to exist."
        cb null, value

    filetype: (check, path, options, value, cb) ->
      return cb null, value unless options.filetype
      fs.stat value, (err, stats) ->
        return cb err if err
        switch options.filetype
          when 'file', 'f'
            return cb null, value if stats.isFile()
            debug "skip #{file} because not a file entry"
          when 'directory', 'dir', 'd'
            return cb null, value if stats.isDirectory()
            debug "skip #{file} because not a directory entry"
          when 'link', 'l'
            return cb null, value if stats.isSymbolicLink()
            debug "skip #{file} because not a link entry"
          when 'fifo', 'pipe', 'p'
            return cb null, value if stats.isFIFO()
            debug "skip #{file} because not a FIFO entry"
          when 'socket', 's'
            return cb null, value if stats.isSocket()
            debug "skip #{file} because not a socket entry"
        return cb check.error path, options, value,
        cb new Error "The given file '#{value}' is not a #{filetype} entry."


  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
      type: 'object'
      allowedKeys: true
      entries:
        type:
          type: 'string'
        title:
          type: 'string'
          optional: true
        description:
          type: 'string'
          optional: true
        optional:
          type: 'boolean'
          optional: true
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
    , options

