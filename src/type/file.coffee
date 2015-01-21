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
# - `find` - (bool) find the given file anywhere in the base directory
# - `filetype` - (string) check against inode type: f, file, d, dir, directory, l, link


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:file')
util = require 'util'
chalk = require 'chalk'
fs = require 'alinex-fs'
fspath = require 'path'
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
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}"
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
        list = fs.findSync basedir,
          include: value
        return null unless list
        value = list[0][basedir.length+1..]
      # resolve
      if options.resolve
        value = fspath.resolve basedir, value
      filepath = fspath.resolve basedir, value
      # exists
      if options.exists
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
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # first check input type
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # sanitize
      value = fspath.normalize value
      value = value[..-2] if value[-1..] is '/'
      # get basedir
      basedir = fspath.resolve options.basedir ? '.'
      # validate
      file.async.find check, path, options, value, (err, value) ->
        return cb err if err
        # resolve
        if options.resolve
          value = fspath.resolve basedir, value
        filepath = fspath.resolve basedir, value
        file.async.exists check, path, options, value, (err, value) ->
          return cb err if err
          file.async.filetype check, path, options, value, (err, value) ->
            return cb err if err
            cb null, value

    find: (check, path, options, value, cb) ->
      return cb null, value unless options.find
      fs.find basedir,
        include: value
      , (err, list) ->
        return cb err if err
        return cb null, null unless list
        cb null, value = list[0][basedir.length+1..]

    exists: (check, path, options, value, cb) ->
      return cb null, value unless options.exists
      fs.exists file, (exists) ->
        unless exists
          return cb check.error path, options, value,
          new Error "The given file '#{value}' has to exist."
        cb null, value

    filetype: (check, path, options, value, cb) ->
      return cb null, value unless options.filetype
      fs.stat file, (err, stats) ->
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
        new Error "The given file '#{value}' is not a #{filetype} entry."


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
          type: 'boolean'
          default: false
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

